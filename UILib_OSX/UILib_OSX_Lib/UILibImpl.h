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


#import "SDKLib/VR.h"

#import "UILibCallback.h"
#import "UILibCtFormLogin.h"


@interface UILibImpl : NSObject

@property(readonly) Object mLock;
@property int mId;
@property id<UILibCallback> mCallback;
@property Handler mHandler;
@property Object mClosure;
@property id<HttpPlugin_RequestFactory> mHttpPlugin;
@property UILibCtFormLogin *mFormLogin;
@property NSString *mServerApiKey;
@property NSString *mServerEndPoint;
@property bool mVRLibInitialized;

- (void)onLoginSuccessInternal:(id<User>)user save:(bool)save;

@end

@interface Runnable : NSOperation

- (void)postSelf:(Handler)handler;

@end

@interface CallbackNotifier : Runnable

- (id)initWith:(UILibImpl *)uiLibImpl;
- (void)onRun:(UILibImpl *)uiLibimpl callback:(id<UILibCallback>)callback closure:(Object)closure;

@end


@interface LoginSuccessNotifier : CallbackNotifier
@end
