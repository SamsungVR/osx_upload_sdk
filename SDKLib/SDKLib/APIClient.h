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

#import <Foundation/Foundation.h>

#import "VR.h"
#import "HttpPlugin.h"
#import "AsyncWorkQueue.h"

@protocol APIClient_Result_Init <VR_Result_SuccessWithResultCallback, VR_Result_FailureCallback>
@end

@protocol APIClient_Result_Destroy <VR_Result_SuccessCallback, VR_Result_FailureCallback>
@end

@protocol APIClient

- (bool)newUser:(NSString *)name email:(NSString *)email password:(NSString *)password
        callback:(id<VR_Result_NewUser>)callback handler:(NSOperationQueue *)handler
        closure:(Object)closure;


@end


@interface APIClient_Factory : NSObject

+ (bool)newInstance:(NSString *)endPoint apiKey:(NSString *)apiKey
        httpRequestFactory:(id<HttpPlugin_RequestFactory>)httpRequestFactory
        callback:(id<APIClient_Result_Init>)callback handler:(NSOperationQueue *)handler
        closure:(Object)closure;

@end
