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
#import "ResultCallbackHolder.h"

@implementation Util

@end

@implementation Util_CallbackNotifier {
    ResultCallbackHolder_Impl *mRCHImpl;
}

- (id)init {
    mRCHImpl = [[ResultCallbackHolder_Impl alloc] init];
    return [super init];
}

- (id)setNoLock:(Object)callback handler:(Handler)handler closure:(Object)closure {
    [mRCHImpl setNoLock:callback handler:handler closure:closure];
    return self;
}

- (id)setNoLock:(id<ResultCallbackHolder>)other {
    [mRCHImpl setNoLock:[other getCallbackNoLock] handler:[other getHandlerNoLock] closure:[other getClosureNoLock]];
    return self;
}

- (id)clearNoLock {
    [mRCHImpl setNoLock:NULL handler:NULL closure:NULL];
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
    id<VR_Result_SuccessCallback> pCasted = callback;
    [pCasted onSuccess:closure];
}

@end

@implementation Util_SuccessWithResultCallbackNotifier {
    Object mRef;
}

- (id)initWithRef:(Object)ref {
    mRef = ref;
    return [super init];
}

- (void)notify:(Object)callback closure:(Object)closure {
    id<VR_Result_SuccessWithResultCallback> pCasted = callback;
    [pCasted onSuccess:closure result:mRef];
}

@end


@implementation Util_FailureCallbackNotifier {
    NSInteger mStatus;
}

- (id)initWithStatus:(NSInteger)status {
    mStatus = status;
    return [super init];
}

- (void)notify:(Object)callback closure:(Object)closure {
    id<VR_Result_FailureCallback> pCasted = callback;
    [pCasted onFailure:closure status:mStatus];
}

@end


@implementation Util_CancelledCallbackNotifier


- (void)notify:(Object)callback closure:(Object)closure {
    id<VR_Result_BaseCallback> pCasted = callback;
    [pCasted onCancelled:closure];
}

@end

@implementation Util_ExceptionCallbackNotifier {
    NSException *mException;
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
