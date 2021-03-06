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

#import "Compat_Defs.h"
#import "AsyncWorkItem.h"

@class APIClient_Impl;

@protocol AsyncWorkQueue_IterationObserver

- (bool)onIterate:(AsyncWorkItem *)workItem args:(Object)args;

@end

@interface AsyncWorkQueue : NSOperationQueue

- (void)destroy;
- (id)initWithAPIClient:(APIClient_Impl *)apiClient;
- (AsyncWorkItem *)obtainWorkItem:(id<AsyncWorkItemType>)type;
- (bool)enqueue:(AsyncWorkItem *)workItem;
- (void)iterateWorkItems:(id<AsyncWorkQueue_IterationObserver>)observer args:(Object)args;

@end

