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
#import "ResultCallbackHolder.h"

@interface Util : NSObject


@end

@interface Util_CallbackNotifier : NSOperation<ResultCallbackHolder>

- (id)init;
- (id)initWithRH:(ResultCallbackHolder_Impl *)rchImpl;
- (void)notify:(Object)callback closure:(Object)closure;
- (bool)post;

@end


@interface Util_SuccessCallbackNotifier : Util_CallbackNotifier
@end

@interface Util_SuccessWithResultCallbackNotifier : Util_CallbackNotifier

- (id)initWithRef:(Object)ref;

@end

@interface Util_FailureCallbackNotifier : Util_CallbackNotifier

- (id)initWithStatus:(NSInteger)status;

@end

@interface Util_CancelledCallbackNotifier : Util_CallbackNotifier
@end

@interface Util_ExceptionCallbackNotifier : Util_CallbackNotifier
@end
