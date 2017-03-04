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
#import "APIClient_Impl.h"

static APIClient_Impl *sAPIClient = NULL;
static NSObject *sLock = NULL;

static id<VR_Result_Init> sInitCallbackApp = nil;
static id<APIClient_Result_Init> sInitCallbackApi = nil;


@interface APIClient_Result_Init_Impl : NSObject<APIClient_Result_Init>

- (void)cleanupNoLock;

@end

@implementation APIClient_Result_Init_Impl

- (void)onSuccess:(Object)closure result:(id)result {
    @synchronized (sLock) {
        sAPIClient = result;
        if (sInitCallbackApp) {
            [sInitCallbackApp onSuccess:closure];
        }
        [self cleanupNoLock];
    }
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
    @synchronized (sLock) {
        if (sInitCallbackApp) {
            [sInitCallbackApp onFailure:closure status:status];
        }
        [self cleanupNoLock];
    }
}

- (void)cleanupNoLock {
    sInitCallbackApp = nil;
    sInitCallbackApi = nil;
}

@end

@implementation VR

+ (void)initialize {
    sLock = [[NSObject alloc] init];
}

+ (bool)initAsync:(NSString *)endPoint apiKey:(NSString *)apiKey
        factory:(id<HttpPlugin_RequestFactory>)factory
        callback:(id<VR_Result_Init>)callback
        handler:(NSOperationQueue *)handler closure:(Object)closure {
    
    @synchronized (sLock) {
        @synchronized (sLock) {
            if (sAPIClient || sInitCallbackApi) {
                return false;
            }
            sInitCallbackApp = callback;
            sInitCallbackApi = [[APIClient_Result_Init_Impl alloc] init];
            return [APIClient_Factory newInstance:endPoint apiKey:apiKey httpRequestFactory:factory
                                         callback:sInitCallbackApi handler:handler closure:closure];
        }
    }
}


@end	
