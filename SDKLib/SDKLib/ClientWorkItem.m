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

#import "ClientWorkItem.h"
#import "APIClient_Impl.h"
#import "ResultCallbackHolder_Impl.h"



@implementation ClientWorkItem {
    APIClient_Impl *mAPIClient;
    ResultCallbackHolder_Impl *mCallbackHolder;
}

- (id)initWith:(APIClient_Impl *)apiClient type:(id<AsyncWorkItemType>)type {
    mAPIClient = apiClient;
    mCallbackHolder = [[ResultCallbackHolder_Impl alloc] init];
    return [super initWithType:type];
}

- (void)main {
    if (![mAPIClient isInitialized]) {
        return;
    }
    [self onRun];
}

- (APIClient_Impl *)getApiClient {
    return mAPIClient;
}
- (void)set:(id<VR_Result_BaseCallback>)callback handler:(Handler)handler closure:(Object)closure {
    [mCallbackHolder setNoLock:callback handler:handler closure:closure];
}

- (NSString *)toRESTUrl:(NSString *)suffix {
    return [NSString stringWithFormat:@"%@/%@", [mAPIClient getEndPoint], suffix];
}


- (id<HttpPlugin_PostRequest>) newPostRequest:(NSString *)suffix headers:(NSString __autoreleasing *[][2])headers {
    NSString *restUrl = [self toRESTUrl:suffix];
    id<HttpPlugin_RequestFactory> reqFactory = [mAPIClient getRequestFactory];
    return [reqFactory newPostRequest:restUrl headers:headers];
}

- (void)writeBytes:(id<HttpPlugin_WritableRequest>)request data:(NSData *)data debugMsg:(NSString *)debugMsg {
    NSInputStream *stream = [[NSInputStream alloc] initWithData:data];
    [request output:stream buf:nil];
    [stream close];
}

- (int)getResponseCode:(id<HttpPlugin_ReadableRequest>)request {
    return [request responseCode];
}

- (NSData *)readHttpStream:(id<HttpPlugin_ReadableRequest>)request debugMsg:(NSString *)debugMsg {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSInputStream *stream = [request input];
    uint8_t buf[2048];
    int len;
    
    while ((len = [stream read:buf maxLength:2048]) > 0) {
        [data appendBytes:buf length:len];
    }
    return data;
}

@end
