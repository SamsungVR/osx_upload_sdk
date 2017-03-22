/*
 * Copyright (c) 2016 Samsung Electronics America
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "APIClient_Impl.h"
#import "AsyncWorkQueue.h"
#import "Util.h"
#import "ClientWorkItem.h"
#import "HttpPlugin.h"
#import "User_Impl.h"

typedef NS_ENUM(NSInteger, State) {
    INITIAILIZING,
    INITIALIZED,
    DESTROYING,
    DESTROYED
};

@interface WorkItemTypePerformLogin : NSObject<AsyncWorkItemType>

@end

@interface WorkItemPerformLogin : ClientWorkItem

- (id)initWithClient:(APIClient_Impl *)apiClient;

@end


@implementation WorkItemTypePerformLogin

- (AsyncWorkItem *)newInstance:(APIClient_Impl *)apiClient {
    return [[WorkItemPerformLogin alloc] initWithClient:apiClient];
}

@end

static id<AsyncWorkItemType> sTypePerformLogin = nil;

@implementation WorkItemPerformLogin {
    NSString *mEmail, *mPassword;
}

- (id)initWithClient:(APIClient_Impl *)apiClient {
    return [super initWith:apiClient type:sTypePerformLogin];
}

- (void)set:(NSString *)email password:(NSString *)password callback:(id<VR_Result_Login>)callback handler:(Handler)handler closure:(Object)closure {
    [super set:callback handler:handler closure:closure];
    mEmail = email;
    mPassword = password;
}

- (void)onRun {
    id<HttpPlugin_PostRequest> request = nil;
    
    NSMutableDictionary *o = [[NSMutableDictionary alloc] init];
    o[@"email"] = mEmail;
    o[@"password"] = mPassword;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:o options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    Headers headers = {
        HEADER_CONTENT_LENGTH, [NSString stringWithFormat:@"%d", [jsonData length]],
        HEADER_CONTENT_TYPE, [NSString stringWithFormat:@"application/json%@", CONTENT_TYPE_CHARSET_SUFFIX_UTF8],
        HEADER_API_KEY, [[self getApiClient] getApiKey],
        NULL
    };
    request = [self newPostRequest:@"user/authenticate" headers:headers];
    [self writeBytes:request data:jsonData debugMsg:nil];
    int responseCode = [self getResponseCode:request];
    NSData *response = [self readHttpStream:request debugMsg:nil];
    if (!response) {
        [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_STREAM_READ_FAILURE];
        return;
    }
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
    
    if ([self isHttpSuccess:responseCode]) {
        User_Impl *user = [[User_Impl alloc] initWith:[self getApiClient] jsonObject:jsonResponse];
        if (user) {
            [self dispatchSuccessWithResult:user];
        } else {
            [self dispatchFailure:VR_RESULT_STATUS_SERVER_RESPONSE_INVALID];
        }
        return;
    }

    NSInteger status = [Util jsonOptInt:jsonResponse key:@"status" def:VR_RESULT_STATUS_SERVER_RESPONSE_NO_STATUS_CODE];
    [self dispatchFailure:status];
}

@end

@implementation APIClient_Impl {
    AsyncWorkQueue *mAsyncWorkQueue;
    AsyncWorkQueue *mAsyncUploadQueue;
    State mState;
    ResultCallbackHolder_Impl *mDestroyCallbackHolder;
    NSInteger mNumAsyncQueues;
    NSString *mEndPoint, *mApiKey;
    id<HttpPlugin_RequestFactory> mRequestFactory;
    
}

+ (void)initialize {
    sTypePerformLogin = [[WorkItemTypePerformLogin alloc] init];
}

- (id)initInternal:(NSString *)endPoint apiKey:(NSString *)apiKey
    httpRequestFactory:(id<HttpPlugin_RequestFactory>)httpRequestFactory {
    mRequestFactory = httpRequestFactory;
    mNumAsyncQueues = 2;
    mAsyncWorkQueue = [[AsyncWorkQueue alloc] initWithAPIClient:self];
    mAsyncUploadQueue = [[AsyncWorkQueue alloc] initWithAPIClient:self];
    mEndPoint = endPoint;
    mApiKey = apiKey;
    mState = INITIALIZED;
    return self;
}

- (id<HttpPlugin_RequestFactory>)getRequestFactory {
    return mRequestFactory;
}

- (NSString *)getEndPoint {
    return mEndPoint;
}

- (NSString *)getApiKey {
    return mApiKey;
}

- (bool)isInitialized {
    @synchronized (self) {
        return (INITIALIZED == mState);
    }
}

- (bool)destroy:(id<APIClient_Result_Destroy>)callback handler:(NSOperationQueue *)handler closure:(Object)closure {
    if (INITIALIZED != mState) {
        return false;
    }
    mDestroyCallbackHolder = [[ResultCallbackHolder_Impl alloc] initWithParams:callback handler:handler closure:closure];
    mState = DESTROYING;
    [mAsyncWorkQueue destroy];
    [mAsyncUploadQueue destroy];
    return true;
}

- (void)onAsyncWorkQueueTerm:(AsyncWorkQueue *)asyncWorkQueue {
    @synchronized (self) {
        mNumAsyncQueues -= 1;
        if (mNumAsyncQueues < 1) {
            if (mDestroyCallbackHolder) {
                [[[Util_SuccessCallbackNotifier alloc] initWithOther:mDestroyCallbackHolder] post];
            }
        }
    }
}

- (bool)login:(NSString *)email password:(NSString *)password callback:(id<VR_Result_Login>)callback
      handler:(NSOperationQueue *)handler closure:(Object)closure {
    @synchronized (self) {
        if (INITIALIZED != mState) {
            return false;
        }
    }
    WorkItemPerformLogin *workItem = [mAsyncWorkQueue obtainWorkItem:sTypePerformLogin];
    [workItem set:email password:password callback:callback handler:handler closure:closure];
    return [mAsyncWorkQueue enqueue:workItem];
}

- (AsyncWorkQueue *)getAsyncWorkQueue {
    return mAsyncWorkQueue;
}

- (AsyncWorkQueue *)getAsyncUploadQueue {
    return mAsyncUploadQueue;
}

@end

@implementation APIClient_Factory

+ (bool)newInstance:(NSString *)endPoint apiKey:(NSString *)apiKey
          httpRequestFactory:(id<HttpPlugin_RequestFactory>)httpRequestFactory
                    callback:(id<APIClient_Result_Init>)callback handler:(NSOperationQueue *)handler
                     closure:(Object)closure {
    id<APIClient> result = [[APIClient_Impl alloc] initInternal:endPoint apiKey:apiKey httpRequestFactory:httpRequestFactory];
    if (callback) {
        [[[Util_SuccessWithResultCallbackNotifier alloc] initWithParamsAndRef:callback handler:handler closure:closure ref:result] post];
    }
    return true;
}


@end
