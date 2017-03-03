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

#import "VR.h"
#import "HttpPlugin.h"


@implementation VR
    
static VR *sVR = nil;
static NSObject *sLock = nil;

+ (void)initialize {
    sLock = [[NSObject alloc] init];
    sVR = [[VR alloc] init];
}

+ (bool)initWithEndpoint:(NSString *)endPoint apiKey:(NSString *)apiKey factory:(id<HttpPlugin_RequestFactory>)factory
                 handler:(NSOperationQueue *)handler closure:(Object)closure {
    @synchronized (sLock) {
        
    }
    VR_Result_Status x = VR_RESULT_STATUS_INVALID_USER_ID;
    return true;
}


@end	
