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


#import "AppUILibCallback.h"

@implementation AppUILibCallback

- (id)init {
   _mSubCallbacks = [[NSMutableArray alloc] init];
   return [super init];
}

- (void)onLibInitStatus:(Object)closure status:(bool)status {
   for (id<UILibCallback> callback in _mSubCallbacks) {
      [callback onLibInitStatus:closure status:status];
   }
}

- (void)onLibDestroyStatus:(Object)closure status:(bool)status {
   for (id<UILibCallback> callback in _mSubCallbacks) {
      [callback onLibDestroyStatus:closure status:status];
   }
}

- (void)onLoginSuccess:(id<User>)user closure:(Object)closure {
   for (id<UILibCallback> callback in _mSubCallbacks) {
      [callback onLoginSuccess:user closure:closure];
   }
}

- (void)onLoginFailure:(Object)closure {
   for (id<UILibCallback> callback in _mSubCallbacks) {
      [callback onLoginFailure:closure];
   }
}

- (void)showLoginUI:(NSView *)loginUI closure:(Object)closure {
   for (id<UILibCallback> callback in _mSubCallbacks) {
      [callback showLoginUI:loginUI closure:closure];
   }
}

@end
