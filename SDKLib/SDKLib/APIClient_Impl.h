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

#import "APIClient.h"
#import "AsyncWorkItem.h"

static const NSString * HEADER_API_KEY = @"X-API-KEY";


@interface APIClient_Impl : NSObject<APIClient>


- (void)onAsyncWorkQueueTerm:(AsyncWorkQueue *)asyncWorkQueue;
- (bool)destroy:(id<APIClient_Result_Destroy>)callback handler:(NSOperationQueue *)handler
        closure:(Object)closure;

- (bool)login:(NSString *)email password:(NSString *)password callback:(id<VR_Result_Login>)callback
      handler:(NSOperationQueue *)handler closure:(Object)closure;
- (bool)loginSamsungAccount:(NSString *)samsung_sso_token auth_server:(NSString *)auth_server
                   callback:(id<VR_Result_LoginSSO>)callback handler:(Handler)handler closure:(Object)closure;

- (AsyncWorkQueue *)getAsyncWorkQueue;
- (AsyncWorkQueue *)getAsyncUploadQueue;
- (bool)isInitialized;

- (NSString *)getEndPoint;
- (NSString *)getApiKey;
- (id<HttpPlugin_RequestFactory>)getRequestFactory;

@end
