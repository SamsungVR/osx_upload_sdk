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


#import <SDKLib/User.h>

#import "UILibImpl.h"


@implementation Runnable

- (void)postSelf:(Handler)handler {
   [handler addOperation:self];
}

@end


@implementation CallbackNotifier {
   UILibImpl *mUILibImpl;
   int mMyId;
}

- (id)initWith:(UILibImpl *)uiLibImpl {
   mUILibImpl = uiLibImpl;
   mMyId = mUILibImpl.mId;
   return [super init];
}

- (void)main {

   int activeId;
   Object closure;
   id<UILibCallback> callback;

   @synchronized (mUILibImpl.mLock) {
      activeId = mUILibImpl.mId;
      closure = mUILibImpl.mClosure;
      callback = mUILibImpl.mCallback;
   }
   if (mMyId != activeId || !callback) {
      return;
   }
   [self onRun:mUILibImpl callback:callback closure:closure];
}

- (void)onRun:(UILibImpl *)uiLibimpl callback:(id<UILibCallback>)callback closure:(Object)closure {
    
}

@end


@implementation LoginSuccessNotifier {
   id<User> mUser;
}

- (id)initWith:(UILibImpl *)uiLibImpl user:(id<User>)user {
   mUser = user;
   return [super initWith:uiLibImpl];
}

- (void)onRun:(UILibImpl *)uiLibImpl callback:(id<UILibCallback>)callback closure:(Object)closure {
   [callback onLoginSuccess:mUser closure:uiLibImpl.mClosure];
}

@end

@implementation UILibImpl {
}

- (void)onLoginSuccessInternal:(id<User>)user save:(bool)save {
   if (save) {
      // save
   }
   [[[LoginSuccessNotifier alloc] initWith:self user:user] postSelf:self.mHandler];
}

@end
