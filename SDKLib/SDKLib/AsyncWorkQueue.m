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

#import "AsyncWorkQueue.h"
#import "APIClient_Impl.h"

@interface TermOp : NSOperation

- (id)initWith:(APIClient_Impl *)apiClient queue:(AsyncWorkQueue *)queue;

@end

@implementation TermOp {
    APIClient_Impl *mAPIClientImpl;
    AsyncWorkQueue *mQueue;
}

- (id)initWith:(APIClient_Impl *)apiClient queue:(AsyncWorkQueue *)queue {
    mAPIClientImpl = apiClient;
    mQueue = queue;
    return [super init];
}

- (void)main {
    [mAPIClientImpl onAsyncWorkQueueTerm:mQueue];
}

@end

@implementation AsyncWorkQueue {
    APIClient_Impl *mAPIClient;
}

- (void)destroy {
    [self cancelAllOperations];
    [self addOperation:[[TermOp alloc] initWith:mAPIClient queue:self]];
    self.suspended = YES;
}

- (id)initWithAPIClient:(APIClient_Impl *)apiClient {
    mAPIClient = apiClient;
    return [self init];
}

@end
