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

typedef NS_ENUM(NSInteger, State) {
    INITIAILIZING,
    INITIALIZED,
    DESTROYING,
    DESTROYED
};

@implementation APIClient_Impl {
    AsyncWorkQueue *mAsyncWorkQueue;
    AsyncWorkQueue *mAsyncUploadQueue;
    State mState;
    ResultCallbackHolder_Impl *mDestroyCallbackHolder;
    NSInteger mNumAsyncQueues;
    
}

- (id)initInternal:(NSString *)endPoint apiKey:(NSString *)apiKey
    httpRequestFactory:(id<HttpPlugin_RequestFactory>)httpRequestFactory {
    
    mNumAsyncQueues = 2;
    mAsyncWorkQueue = [[AsyncWorkQueue alloc] initWithAPIClient:self];
    mAsyncUploadQueue = [[AsyncWorkQueue alloc] initWithAPIClient:self];
    
    mState = INITIALIZED;
    return self;
}


- (bool)destroy:(id<APIClient_Result_Destroy>)callback handler:(NSOperationQueue *)handler closure:(Object)closure {
    if (INITIALIZED != mState) {
        return false;
    }
    mDestroyCallbackHolder = [[ResultCallbackHolder_Impl alloc] initWith:callback handler:handler closure:closure];
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
                [[[Util_SuccessCallbackNotifier alloc] initWithRH:mDestroyCallbackHolder] post];
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
    return true;
}

@end

@implementation APIClient_Factory

+ (bool)newInstance:(NSString *)endPoint apiKey:(NSString *)apiKey
          httpRequestFactory:(id<HttpPlugin_RequestFactory>)httpRequestFactory
                    callback:(id<APIClient_Result_Init>)callback handler:(NSOperationQueue *)handler
                     closure:(Object)closure {
    id<APIClient> result = [[APIClient_Impl alloc] initInternal:endPoint apiKey:apiKey httpRequestFactory:httpRequestFactory];
    if (callback) {
        [[[[Util_SuccessWithResultCallbackNotifier alloc] initWithRef:result] setNoLock:callback handler:handler closure:closure] post];
    }
    return true;
}


@end
