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

#import "UILib.h"
#import "UILibCtFormLogin.h"

#import <SDKLib/HttpPlugin_RequestFactory_Impl.h>

#import <Cocoa/Cocoa.h>

static Handler sMainHandler = NULL;

@interface Runnable : NSOperation

- (void)postSelf:(Handler)handler;

@end

@implementation Runnable

- (void)postSelf:(Handler)handler {
   [handler addOperation:self];
}

@end


@interface UILib_Impl : NSObject

@property(nonatomic, readonly) Object mLock;
@property(nonatomic) int mId;
@property(nonatomic) id<UILib_Callback> mCallback;
@property(nonatomic) Handler mHandler;
@property(nonatomic) Object mClosure;
@property(nonatomic) id<HttpPlugin_RequestFactory> mHttpPlugin;
@property(nonatomic) UILibCtFormLogin *mFormLogin;
@property(nonatomic) NSString *mServerApiKey;
@property(nonatomic) NSString *mServerEndPoint;
@property(nonatomic) bool mVRLibInitialized;

@end

@implementation UILib_Impl {
}

@end

@interface CallbackNotifier : Runnable

- (id)initWith:(UILib_Impl *)uiLibImpl;
- (void)onRun:(id<UILib_Callback>)callback closure:(Object)closure;

@end

@implementation CallbackNotifier {
   UILib_Impl *mUILibImpl;
   int mMyId;
}

- (id)initWith:(UILib_Impl *)uiLibImpl {
   mUILibImpl = uiLibImpl;
   mMyId = mUILibImpl.mId;
   return [super init];
}

- (void)main {

   int activeId;
   Object closure;
   id<UILib_Callback> callback;

   @synchronized (mUILibImpl.mLock) {
      activeId = mUILibImpl.mId;
      closure = mUILibImpl.mClosure;
      callback = mUILibImpl.mCallback;
   }
   if (mMyId != activeId || !callback) {
      return;
   }
   [self onRun:callback closure:closure];
}

@end

@interface InitStatusNotifier : CallbackNotifier

- (id)initWith:(UILib_Impl *)uiLibImpl status:(bool)status;

@end

@implementation InitStatusNotifier {
   bool mStatus;
}

- (id)initWith:(UILib_Impl *)uiLibImpl status:(bool)status {
   mStatus = status;
}

- (void)onRun:(id<UILib_Callback>)callback closure:(Object)closure {
   [callback onLibInitStatus:closure status:mStatus];
}

@end

static UILib_Impl *sUILibImpl = NULL;
static NSBundle *sResBundle = NULL;

@interface InitRunnable : Runnable<VR_Result_Destroy>
@end


@implementation InitRunnable {

   NSString *mServerEndPoint, *mServerApiKey, *mSSOAppId, *mSSOAppSecret;
   id<UILib_Callback> mCallback;
   Handler mHandler;
   Object mClosure;
   id<HttpPlugin_RequestFactory> mHttpPlugin;
}

- (id)initWith:(NSString *)serverEndPoint serverApiKey:(NSString *)serverApiKey ssoAppId:(NSString *)ssoAppId
  ssoAppSecret:(NSString *)ssoAppSecret httpPlugin:(id<HttpPlugin_RequestFactory>)httpPlugin callback:(id<UILib_Callback>)callback
       handler:(Handler)handler closure:(Object)closure {

   mClosure = closure;
   mHandler = handler;
   mCallback = callback;
   mServerEndPoint = serverEndPoint;
   mServerApiKey = serverApiKey;
   mSSOAppId = ssoAppId;
   mSSOAppSecret = ssoAppSecret;
   mHttpPlugin = httpPlugin;
   return [super init];
}

- (void) main {
   UILib_Impl *impl = sUILibImpl;

   @synchronized (impl.mLock) {
      impl.mId += 1;
      impl.mCallback = mCallback;
      impl.mHandler = !mHandler ? sMainHandler : mHandler;
      impl.mClosure = mClosure;
      impl.mHttpPlugin = !mHttpPlugin ? [[HttpPlugin_RequestFactory_Impl alloc] init] : mHttpPlugin;
   }

   NSString *currentSSOAppSecret = NULL, *currentSSOAppId = NULL, *currentServerEndPoint = NULL, *currentServerApiKey = NULL;

   if (!impl.mFormLogin) {
      currentSSOAppId = impl.mFormLogin.mSSOAppId;
      currentSSOAppSecret = impl.mFormLogin.mSSOAppSecret;
      currentServerApiKey = impl.mServerApiKey;
      currentServerEndPoint = impl.mServerEndPoint;
   }


   bool matches = (currentSSOAppSecret == mSSOAppSecret || currentSSOAppSecret && [currentSSOAppSecret isEqualToString:mSSOAppSecret]) &&
   (currentSSOAppId == mSSOAppId || !currentSSOAppId && [currentSSOAppId isEqualToString:mSSOAppId]) &&
   (currentServerEndPoint == mServerEndPoint || currentServerEndPoint && [currentServerEndPoint isEqualToString:mServerEndPoint]) &&
   (currentServerApiKey == mServerApiKey || currentServerApiKey && [currentServerApiKey isEqualToString:mServerApiKey]);

   if (impl.mVRLibInitialized) {
      if (matches) {
         [[[InitStatusNotifier alloc] initWith:impl status:true] postSelf:impl.mHandler];
         return;
      }
      [VR destroyAsync:self handler:sMainHandler closure:nil];
      return;
   }

   onSuccess(NULL);
}

- (void)onFailure:(Object)closure status:(int)status {
   [[[InitStatusNotifier alloc] initWith:sUILibImpl status:false] postSelf:mHandler];
}

- (void)onSuccess:(Object)closure {
   UILib_Impl *impl = sUILibImpl;

   impl.mServerApiKey = mServerApiKey;
   impl.mServerEndPoint = mServerEndPoint;
   impl.mFormLogin = [[UILibCtFormLogin alloc] initWithNibName:@"UILibFormLogin" bundle:sResBundle];
   impl.mFormLogin.mSSOAppId = mSSOAppId;
   impl.mFormLogin.mSSOAppSecret = mSSOAppSecret;

   //if ([VR initAsync:impl.mServerEndPoint serverApiKey:impl.mServerApiKey httpPlugin:impl.mHttpPlugin  new VRInitCallback(), sMainHandler, mClosure)) {
   //      new InitStatusNotifier(impl, false).postSelf(impl.mHandler);
   //   }

}

@end

@implementation UILib

static NSWindow *mTemp;
static NSWindowController *mTemp2;
static UILibCtFormLogin *mFormLogin;

static NSObject *sLock = NULL;


+ (void)initialize {
   sLock = [[NSObject alloc] init];
   sMainHandler = [NSOperationQueue mainQueue];
   sUILibImpl = [[UILib_Impl alloc] init];
   sResBundle = [NSBundle bundleWithPath:@"Res.bundle"];
}

+ (void)test {
   NSRect contentSize = NSMakeRect(500.0, 500.0, 1000.0, 1000.0);
   NSUInteger windowStyleMask = NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask;
   mTemp = [[NSWindow alloc] initWithContentRect:contentSize styleMask:windowStyleMask backing:NSBackingStoreBuffered defer:YES];

   mTemp2 = [[NSWindowController alloc] initWithWindow:mTemp];
   [mTemp2 showWindow:nil];

   NSBundle *bundle = [NSBundle bundleWithPath:@"Res.bundle"];

   //bundle = [NSBundle mainBundle];
   mFormLogin = [[UILibCtFormLogin alloc] initWithNibName:@"UILibFormLogin" bundle:bundle];
   NSView *subView = [mFormLogin view];
   NSLog(@"subView: %f %f", subView.frame.size.width, subView.frame.size.height);
   if (subView) {
      NSSize controlSize = subView.frame.size;
      NSWindow *window = [mTemp2 window];
      [window setContentSize:controlSize];
      [[window contentView] addSubview:subView];
      [mFormLogin onLoad];
   }
}

+ (bool)init:(NSString *)serverEndPoint serverApiKey:(NSString *)serverApiKey ssoAppId:(NSString *)ssoAppId
   ssoAppSecret:(NSString *)ssoAppSecret httpPlugin:(id<HttpPlugin_RequestFactory>)httpPlugin
   callback:(id<UILib_Callback>)callback handler:(Handler)handler                     closure:(Object)closure {

   [[[InitRunnable alloc] initWith:serverEndPoint serverApiKey:serverApiKey ssoAppId:ssoAppId  ssoAppSecret:ssoAppSecret httpPlugin:httpPlugin
                          callback:callback handler:handler closure:closure] postSelf:sMainHandler];
   return true;
}


@end
