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
#import "Util.h"


@implementation ClientWorkItem_CancelledCallbackNotifier

- (void)notify:(Object)callback closure:(Object)closure {
    id<VR_Result_BaseCallback> pCasted = callback;
    [pCasted onCancelled:closure];
}

@end

@implementation ClientWorkItem_ExceptionCallbackNotifier {
    NSException *mException;
}

- (id)initWithParamsAndException:(Object)callback handler:(Handler)handler closure:(Object)closure exception:(NSException *)exception {
    mException = exception;
    return [super initWithParams:callback handler:handler closure:closure];
}
- (id)initWithOtherAndException:(id<ResultCallbackHolder>)other exception:(NSException *)exception {
    mException = exception;
    return [super initWithOther:other];
}

- (id)initWithException:(NSException *)exception {
    mException = exception;
    return [super init];
}

- (void)notify:(Object)callback closure:(Object)closure {
    id<VR_Result_BaseCallback> pCasted = callback;
    [pCasted onException:closure ex:mException];
}

@end

@implementation ClientWorkItem {
    APIClient_Impl *mAPIClient;
    ResultCallbackHolder_Impl *mCallbackHolder;
    int mDispatchCounted;
}

- (id)initWith:(APIClient_Impl *)apiClient type:(id<AsyncWorkItemType>)type {
    mAPIClient = apiClient;
    mDispatchCounted = 0;
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
    return [request input];
}

- (bool)isHttpSuccess:(NSInteger)statusCode {
    return statusCode >= 200 && statusCode < 400;
}


- (void)set:(id<ResultCallbackHolder>)other {
    [mCallbackHolder setNoLock:other];
}

- (void)set:(Object)callback handler:(Handler)handler closure:(Object)closure {
    [mCallbackHolder setNoLock:callback handler:handler closure:closure];
}

- (Object)getClosure {
    return [mCallbackHolder getClosureNoLock];
}

- (Handler)getHandler {
    return [mCallbackHolder getHandlerNoLock];
}

- (id<ResultCallbackHolder>) getCallbackHolder {
    return mCallbackHolder;
}

- (void)dispatchUncounted:(Util_CallbackNotifier *)notifier {
    [notifier post];
}

- (void)dispatchCounted:(Util_CallbackNotifier *)notifier {
    [self dispatchUncounted:notifier];
    mDispatchCounted += 1;
    [self onDispatchCounted:mDispatchCounted];
}

- (void)dispatchSuccessWithResult:(Object)rf {
    [self dispatchCounted:[[Util_SuccessWithResultCallbackNotifier alloc] initWithOtherAndRef:mCallbackHolder ref:rf]] ;
}

- (void) dispatchException:(NSException *)exception {
    [self dispatchCounted:[[ClientWorkItem_ExceptionCallbackNotifier alloc] initWithOtherAndException:mCallbackHolder exception:exception]];
}

- (void)onDispatchCounted:(int)count {
    
}

@end
