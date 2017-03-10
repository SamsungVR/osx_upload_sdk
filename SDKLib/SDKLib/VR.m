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

#import "Util.h"
#import "VR.h"
#import "HttpPlugin.h"
#import "APIClient_Impl.h"
#import "HttpPlugin_RequestFactory_Impl.h"

static APIClient_Impl *sAPIClient = NULL;
static NSObject *sLock = NULL;

static id<VR_Result_Init> sInitCallbackApp = nil;
static id<APIClient_Result_Init> sInitCallbackApi = nil;
static id<VR_Result_Destroy> sDestroyCallbackApp = nil;
static id<APIClient_Result_Destroy> sDestroyCallbackApi = nil;

@interface APIClient_Result_Destroy_Impl : NSObject<APIClient_Result_Destroy>

- (void)cleanupNoLock;

@end

@implementation APIClient_Result_Destroy_Impl

- (void)onSuccess:(Object)closure {
    @synchronized (sLock) {
        sAPIClient = NULL;
        
        if (sDestroyCallbackApp) {
            [sDestroyCallbackApp onSuccess:closure];
        }
        [self cleanupNoLock];
    }
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
    @synchronized (sLock) {
        if (sDestroyCallbackApp) {
            [sDestroyCallbackApp onFailure:closure status:status];
        }
        [self cleanupNoLock];
    }
}

- (void)cleanupNoLock {
    sDestroyCallbackApp = nil;
    sDestroyCallbackApi = nil;
}

@end

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
        if (sAPIClient || sInitCallbackApi) {
            return false;
        }
        sInitCallbackApp = callback;
        sInitCallbackApi = [[APIClient_Result_Init_Impl alloc] init];
        return [APIClient_Factory newInstance:endPoint apiKey:apiKey httpRequestFactory:factory
                                     callback:sInitCallbackApi handler:handler closure:closure];
    }
}

+ (bool)initAsync:(NSString *)endPoint apiKey:(NSString *)apiKey
         callback:(id<VR_Result_Init>)callback
          handler:(NSOperationQueue *)handler closure:(Object)closure {
    return [self initAsync:endPoint apiKey:apiKey factory:[[HttpPlugin_RequestFactory_Impl alloc] init]
                  callback:callback handler:handler closure:closure];
}


+ (bool)destroyAsync:(id<VR_Result_Destroy>)callback handler:(NSOperationQueue *)handler closure:(Object)closure {
    @synchronized (sLock) {
        if (sInitCallbackApi || sDestroyCallbackApi) {
            return false;
        }
        APIClient_Result_Destroy_Impl *temp = [[APIClient_Result_Destroy_Impl alloc] init];
        if (!sAPIClient) {
            sDestroyCallbackApi = temp;
            sDestroyCallbackApp = callback;
            [[[[Util_SuccessCallbackNotifier alloc] init] setNoLock:sDestroyCallbackApi handler:handler closure:closure] post];
            return true;
        }
        if ([sAPIClient destroy:temp handler:nil closure:nil]) {
            sDestroyCallbackApp = callback;
            sDestroyCallbackApi = temp;
            return true;
        }
        return false;
    }

}

+ (bool)login:(NSString *)email password:(NSString *)password callback:(id<VR_Result_Login>)callback
      handler:(NSOperationQueue *)handler closure:(Object)closure {
    @synchronized (sLock) {
        if (!sAPIClient) {
            return false;
        }
        return [sAPIClient login:email password:password callback:callback handler:handler closure:closure];
    }
}

@end
