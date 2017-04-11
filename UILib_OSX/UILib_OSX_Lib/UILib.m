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
#import "UILibImpl.h"
#import "UILibCtFormLogin.h"

#import <SDKLib/HttpPlugin_RequestFactory_Impl.h>
#import <Cocoa/Cocoa.h>

static Handler sMainHandler = NULL;



@interface InitStatusNotifier : CallbackNotifier

- (id)initWith:(UILibImpl *)uiLibImpl status:(bool)status;

@end

@implementation InitStatusNotifier {
   bool mStatus;
}

- (id)initWith:(UILibImpl *)uiLibImpl status:(bool)status {
   mStatus = status;
   return [super initWith:uiLibImpl];
}

- (void)onRun:(UILibImpl *)uiLibImpl callback:(id<UILibCallback>)callback closure:(Object)closure {
   [callback onLibInitStatus:closure status:mStatus];
}

@end

static UILibImpl *sUILibImpl = NULL;
static NSBundle *sResBundle = NULL;

@interface UILibVRInitCallback : NSObject<VR_Result_Init>
@end

@implementation UILibVRInitCallback

- (void)onSuccess:(Object)closure {
   UILibImpl *impl = sUILibImpl;
   impl.mVRLibInitialized = true;
   [[[InitStatusNotifier alloc] initWith:impl status:true] postSelf:impl.mHandler];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   UILibImpl *impl = sUILibImpl;
   [[[InitStatusNotifier alloc] initWith:impl status:false] postSelf:impl.mHandler];
}

@end


@interface InitRunnable : Runnable<VR_Result_Destroy>
@end


@implementation InitRunnable {

   NSString *mServerEndPoint, *mServerApiKey, *mSSOAppId, *mSSOAppSecret;
   id<UILibCallback> mCallback;
   Handler mHandler;
   Object mClosure;
   id<HttpPlugin_RequestFactory> mHttpPlugin;
}

- (id)initWith:(NSString *)serverEndPoint serverApiKey:(NSString *)serverApiKey ssoAppId:(NSString *)ssoAppId
  ssoAppSecret:(NSString *)ssoAppSecret httpPlugin:(id<HttpPlugin_RequestFactory>)httpPlugin callback:(id<UILibCallback>)callback
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
   UILibImpl *impl = sUILibImpl;

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


   bool matches = (currentSSOAppSecret == mSSOAppSecret || (currentSSOAppSecret && [currentSSOAppSecret isEqualToString:mSSOAppSecret])) &&
   (currentSSOAppId == mSSOAppId || (currentSSOAppId && [currentSSOAppId isEqualToString:mSSOAppId])) &&
   (currentServerEndPoint == mServerEndPoint || (currentServerEndPoint && [currentServerEndPoint isEqualToString:mServerEndPoint])) &&
   (currentServerApiKey == mServerApiKey || (currentServerApiKey && [currentServerApiKey isEqualToString:mServerApiKey]));

   if (impl.mVRLibInitialized) {
      if (matches) {
         [[[InitStatusNotifier alloc] initWith:impl status:true] postSelf:impl.mHandler];
         return;
      }
      [VR destroyAsync:self handler:sMainHandler closure:nil];
      return;
   }

   [self onSuccess:nil];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   [[[InitStatusNotifier alloc] initWith:sUILibImpl status:false] postSelf:mHandler];
}

- (void)onSuccess:(Object)closure {
   UILibImpl *impl = sUILibImpl;

   impl.mServerApiKey = mServerApiKey;
   impl.mServerEndPoint = mServerEndPoint;
   impl.mFormLogin = [[UILibCtFormLogin alloc] initWith:impl bundle:sResBundle];
   impl.mFormLogin.mSSOAppId = mSSOAppId;
   impl.mFormLogin.mSSOAppSecret = mSSOAppSecret;


   if ([VR initAsync:impl.mServerEndPoint apiKey:impl.mServerApiKey factory:impl.mHttpPlugin  callback:[[UILibVRInitCallback alloc] init] handler:sMainHandler closure:mClosure]) {
      [[[InitStatusNotifier alloc] initWith:impl status:false] postSelf:impl.mHandler];
   }

}

@end


@interface ShowLoginUINotifier : CallbackNotifier
@end

@implementation ShowLoginUINotifier

- (id)initWith:(UILibImpl *)uiLibImpl {
   return [super initWith:uiLibImpl];
}

- (void)onRun:(UILibImpl *)uiLibImpl callback:(id<UILibCallback>)callback closure:(Object)closure {
   [callback showLoginUI:[uiLibImpl.mFormLogin view] closure:uiLibImpl.mClosure];
}

@end



@interface LoginRunnable : Runnable
@end

@implementation LoginRunnable

- (void)showLoginUI {
   UILibImpl *impl = sUILibImpl;
   [impl.mFormLogin toLoginPage];
   [[[ShowLoginUINotifier alloc] initWith:impl] postSelf:impl.mHandler];
}

- (void)main {
   [self showLoginUI];
}

@end

/*
internal class LoginRunnable : Runnable, SDKLib.VR.Result.GetUserBySessionToken.If {

   public override void run() {
      UILibImpl impl = sUILib;
      string userId = UILibSettings.Default.userId;
      string userSessionToken = UILibSettings.Default.userSessionToken;
      if (null != userId && null != userSessionToken &&
          SDKLib.VR.getUserBySessionToken(userId, userSessionToken, this, sMainHandler, null)) {
         return;
      }
      showLoginUI();
   }

   private void showLoginUI() {

   }

   public void onFailure(object closure, int status) {
      showLoginUI();
   }

   public void onSuccess(object closure, SDKLib.User.If user) {
      sUILib.onLoginSuccessInternal(user, false);
   }

   public void onCancelled(object closure) {
   }

   public void onException(object closure, Exception ex) {
      showLoginUI();
   }
}
*/


@implementation UILib

static NSObject *sLock = NULL;


+ (void)initialize {
   sLock = [[NSObject alloc] init];
   sMainHandler = [NSOperationQueue mainQueue];
   sUILibImpl = [[UILibImpl alloc] init];
   sResBundle = [NSBundle bundleWithPath:@"Res.bundle"];
}


+ (bool)initWith:(NSString *)serverEndPoint serverApiKey:(NSString *)serverApiKey ssoAppId:(NSString *)ssoAppId
   ssoAppSecret:(NSString *)ssoAppSecret httpPlugin:(id<HttpPlugin_RequestFactory>)httpPlugin
   callback:(id<UILibCallback>)callback handler:(Handler)handler closure:(Object)closure {

   [[[InitRunnable alloc] initWith:serverEndPoint serverApiKey:serverApiKey ssoAppId:ssoAppId  ssoAppSecret:ssoAppSecret httpPlugin:httpPlugin
                          callback:callback handler:handler closure:closure] postSelf:sMainHandler];
   return true;
}

+ (bool)login {
   [[[LoginRunnable alloc] init] postSelf:sMainHandler];
   return true;
}

@end
