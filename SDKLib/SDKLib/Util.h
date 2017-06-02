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
#import "ResultCallbackHolder_Impl.h"

@interface Util : NSObject

+ (id)jsonOptObj:(NSDictionary *)jsonObject key:(NSString *)key def:(id)def;
+ (NSInteger)jsonOptInt:(NSDictionary *)jsonObject key:(NSString *)key def:(NSInteger)def;
+ (bool)checkEquals:(Object)a b:(Object)b;

@end

@interface Util_CallbackNotifier : NSOperation<ResultCallbackHolder>

- (void)notify:(id)callback closure:(Object)closure;
- (bool)post;

@end


@interface Util_SuccessCallbackNotifier : Util_CallbackNotifier
@end

@interface Util_SuccessWithResultCallbackNotifier : Util_CallbackNotifier

- (id)initWithParamsAndRef:(id)callback handler:(Handler)handler closure:(Object)closure ref:(id)ref;
- (id)initWithOtherAndRef:(id<ResultCallbackHolder>)other ref:(id)ref;

@end

@interface Util_FailureCallbackNotifier : Util_CallbackNotifier

- (id)initWithParamsAndStatus:(id)callback handler:(Handler)handler closure:(Object)closure status:(NSInteger)status;
- (id)initWithOtherAndStatus:(id<ResultCallbackHolder>)other status:(NSInteger)status;

@end

@interface Util_CancelledCallbackNotifier : Util_CallbackNotifier

- (id)initWithParams:(id)callback handler:(Handler)handler closure:(Object)closure;
- (id)initWithOther:(id<ResultCallbackHolder>)other;

@end

