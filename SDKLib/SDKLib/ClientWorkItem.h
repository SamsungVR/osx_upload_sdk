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


#import "AsyncWorkItem.h"
#import "VR.h"
#import "Util.h"

typedef NS_ENUM(NSInteger, HttpMethod) {
    GET,
    POST,
    DELETE,
    PUT
};

static const NSString * HEADER_CONTENT_TYPE = @"Content-Type";
static const NSString * HEADER_CONTENT_LENGTH = @"Content-Length";
static const NSString * HEADER_CONTENT_DISPOSITION = @"Content-Disposition";
static const NSString * HEADER_CONTENT_TRANSFER_ENCODING = @"Content-Transfer-Encoding";
static const NSString * HEADER_COOKIE = @"Cookie";
static const NSString * CONTENT_TYPE_CHARSET_SUFFIX_UTF8 = @"; charset=utf-8";
static const NSString * HEADER_TRANSFER_ENCODING = @"Transfer-Encoding";
static const NSString * TRANSFER_ENCODING_CHUNKED = @"chunked";

@interface ClientWorkItem_CancelledCallbackNotifier : Util_CallbackNotifier
@end

@interface ClientWorkItem_ExceptionCallbackNotifier : Util_CallbackNotifier

- (id)initWithParamsAndException:(Object)callback handler:(Handler)handler closure:(Object)closure exception:(NSException *)exception;
- (id)initWithOtherAndException:(id<ResultCallbackHolder>)other exception:(NSException *)exception;

@end

@interface ClientWorkItem : AsyncWorkItem

- (id)initWith:(APIClient_Impl *)apiClient type:(id<AsyncWorkItemType>)type;
- (void)onRun;

- (id<HttpPlugin_PostRequest>) newPostRequest:(NSString *)suffix headers:(Headers)headers;
- (id<HttpPlugin_GetRequest>) newGetRequest:(NSString *)suffix headers:(Headers)headers;
- (id<HttpPlugin_DeleteRequest>) newDeleteRequest:(NSString *)suffix headers:(Headers)headers;

- (APIClient_Impl *)getApiClient;
- (void)writeBytes:(id<HttpPlugin_WritableRequest>)request data:(NSData *)data debugMsg:(NSString *)debugMsg;
- (int)getResponseCode:(id<HttpPlugin_ReadableRequest>)request;
- (NSData *)readHttpStream:(id<HttpPlugin_ReadableRequest>)request debugMsg:(NSString *)debugMsg;
- (bool)isHttpSuccess:(NSInteger)statusCode;

- (void)set:(id<ResultCallbackHolder>)other;
- (void)set:(Object)callback handler:(Handler)handler closure:(Object)closure;
- (id<ResultCallbackHolder>) getCallbackHolder;
- (Object)getClosure;
- (Handler)getHandler;

- (void)dispatchSuccessWithResult:(Object)rf;
- (void)dispatchSuccess;
- (void)dispatchFailure:(int)status;

@end
