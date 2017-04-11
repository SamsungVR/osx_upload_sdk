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
#import "Util.h"
#import "ResultCallbackHolder_Impl.h"

@implementation Util

+ (id)jsonOptObj:(NSDictionary *)jsonObject key:(NSString *)key def:(id)def {
    id result = jsonObject[key];
    return (result) ? result : def;
}

+ (NSInteger)jsonOptInt:(NSDictionary *)jsonObject key:(NSString *)key def:(NSInteger)def {
    NSInteger result = (NSInteger)jsonObject[key];
    if (!result) {
        result = def;
    }
    return result;
}


@end

@implementation Util_CallbackNotifier {
    ResultCallbackHolder_Impl *mRCHImpl;
}


- (id)initWithParams:(id)callback handler:(Handler)handler closure:(Object)closure {
    mRCHImpl = [[ResultCallbackHolder_Impl alloc] init];
    [mRCHImpl setNoLock:callback handler:handler closure:closure];
    return [super init];
}

- (id)initWithOther:(id<ResultCallbackHolder>)other {
    mRCHImpl = [[ResultCallbackHolder_Impl alloc] init];
    [mRCHImpl setNoLock:other];
    return [super init];
}

- (id)setNoLock:(Object)callback handler:(Handler)handler closure:(Object)closure {
    [mRCHImpl setNoLock:callback handler:handler closure:closure];
    return self;
}

- (id)setNoLock:(id<ResultCallbackHolder>)other {
    [mRCHImpl setNoLock:other];
    return self;
}

- (id)clearNoLock {
    [mRCHImpl clearNoLock];
    return self;
}

- (Object)getClosureNoLock {
    return [mRCHImpl getClosureNoLock];
}

- (Object)getCallbackNoLock {
    return [mRCHImpl getCallbackNoLock];
}

- (Handler)getHandlerNoLock {
    return [mRCHImpl getHandlerNoLock];
}

- (void)notify:(Object)callback closure:(Object)closure {
}

- (void)main {
    Object callback = [self getCallbackNoLock];
    if (!callback) {
        return;
    }
    [self notify:callback closure:[self getClosureNoLock]];
}

- (bool)post {
    Handler handler = [self getHandlerNoLock];
    if (handler) {
        [handler addOperation:self];
    }
    return true;
}

@end

@implementation Util_SuccessCallbackNotifier

- (void)notify:(Object)callback closure:(Object)closure {
    id<VR_Result_SuccessCallback> pCasted = (id<VR_Result_SuccessCallback>)callback;
    [pCasted onSuccess:closure];
}

@end

@implementation Util_SuccessWithResultCallbackNotifier {
    Object mRef;
}

- (id)initWithParamsAndRef:(id)callback handler:(Handler)handler closure:(Object)closure ref:(Object)ref {
    mRef = ref;
    return [super initWithParams:callback handler:handler closure:closure];
}

- (id)initWithOtherAndRef:(id<ResultCallbackHolder>)other ref:(Object)ref {
    mRef = ref;
    return [super initWithOther:other];
}

- (void)notify:(Object)callback closure:(Object)closure {
    id<VR_Result_SuccessWithResultCallback> pCasted = (id<VR_Result_SuccessWithResultCallback>)callback;
    [pCasted onSuccess:closure result:mRef];
}

@end


@implementation Util_FailureCallbackNotifier {
    NSInteger mStatus;
}


- (id)initWithParamsAndStatus:(Object)callback handler:(Handler)handler closure:(Object)closure status:(NSInteger)status {
    mStatus = status;
    return [super initWithParams:callback handler:handler closure:closure];
}

- (id)initWithOtherAndStatus:(id<ResultCallbackHolder>)other status:(NSInteger)status {
    mStatus = status;
    return [super initWithOther:other];
}

- (void)notify:(id)callback closure:(Object)closure {
    id<VR_Result_FailureCallback> pCasted = (id<VR_Result_FailureCallback>)callback;
    [pCasted onFailure:closure status:mStatus];
}

@end

