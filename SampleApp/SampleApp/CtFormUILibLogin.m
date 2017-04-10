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

#import "DgApp.h"
#import "CtFormUILibLogin.h"
#import "CtFormEndPointConfig.h"
#import "CtFormLoggedIn.h"
#import "AppUtil.h"

#import <SDKLib/VR.h>
#import <SDKLib/User.h>

@interface FormUILibCallbackInit : NSObject<VR_Result_Init>

- (id)initWith:(CtFormUILibLogin *)form;

@end

@interface FormUILibCallbackDestroy : NSObject<VR_Result_Destroy>

- (id)initWith:(CtFormUILibLogin *)form;

@end

@interface FormUILibCallbackLogin : NSObject<VR_Result_Login>

- (id)initWith:(CtFormUILibLogin *)form;

@end


@implementation CtFormUILibLogin {
   NSControl *mCtrlLogin;
   NSButton *mCtrlEndPoint;
   NSTextField *mCtrlStatusMsg, *mCtrlUsername, *mCtrlPassword;
   NSProgressIndicator *mCtrlWaitProgressIndicator;

   EndPointConfigManager *mCfgMgr;
   FormUILibCallbackInit *mCallbackInit;
   FormUILibCallbackDestroy *mCallbackDestroy;
   FormUILibCallbackLogin *mCallbackLogin;

   NSView *mCtrlWaitPanel, *mCtrlLoginPanel;
}

- (void)showWaitPanel {
   [mCtrlWaitPanel setHidden:NO];
   [mCtrlLoginPanel setHidden:YES];
   [mCtrlWaitProgressIndicator startAnimation:nil];
}

- (void)hideWaitPanel {
   [mCtrlWaitPanel setHidden:YES];
   [mCtrlLoginPanel setHidden:NO];
   [mCtrlWaitProgressIndicator stopAnimation:nil];
}

- (void)onLibInitStatus:(Object)closure status:(bool)status {
   if (status) {
      [UILib login];
   }
}

- (void)onLibDestroyStatus:(Object)closure status:(bool)status {
}

- (void)onLoginSuccess:(id<User>)user closure:(Object)closure {
   NSString *tmpl = NSLocalizedString(@"LoggedInAs", nil);
   NSString *msg = [NSString stringWithFormat:tmpl, [user getName]];
   [self setStatusMsg:msg];

   DgApp *dgApp = [DgApp getDgInstance];
   [dgApp setUser:user];
   [dgApp showForm:[CtFormLoggedIn alloc] nibName:@"FormLoggedIn"];

}

- (void)onLoginFailure:(Object)closure {
}

- (void)showLoginUI:(NSView *)loginUI closure:(Object)closure {
   [AppUtil removeAllSubViews:mCtrlLoginPanel];
   [mCtrlLoginPanel addSubview:loginUI];
   [self hideWaitPanel];
   [self setLocalizedStatusMsg:@"Success"];
}

- (void)onCtrlEndPointClick {
   [[DgApp getDgInstance] showForm:[CtFormEndPointConfig alloc] nibName:@"FormEndPointConfig"];
}

- (void)onCtrlLoginClick {
   [VR login:[mCtrlUsername stringValue] password:[mCtrlPassword stringValue]
     callback:mCallbackLogin handler:nil closure:nil];
}

- (void)onLoad {
   [super onLoad];


   DgApp *dgApp = [DgApp getDgInstance];
   [[dgApp getAppUILibCallback].mSubCallbacks addObject:self];
   [dgApp setUser:nil];

   mCfgMgr = [dgApp getEndPointCfgMgr];
   mCallbackInit = [[FormUILibCallbackInit alloc] initWith:self];
   mCallbackDestroy = [[FormUILibCallbackDestroy alloc] initWith:self];
   mCallbackLogin = [[FormUILibCallbackLogin alloc] initWith:self];
   
   NSView *root = [self view];
   mCtrlLoginPanel = [AppUtil findViewById:root identifier:@"ctrlLoginPanel"];
   mCtrlWaitPanel = [AppUtil findViewById:root identifier:@"ctrlWaitPanel"];
   mCtrlWaitProgressIndicator = (NSProgressIndicator *)[AppUtil findViewById:root identifier:@"ctrlWaitProgressIndicator"];

   mCtrlLogin = [AppUtil setActionHandler:root identifier:@"ctrlLogin" target:self action:@selector(onCtrlLoginClick)];
   mCtrlStatusMsg = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlStatusMsg"];
   mCtrlUsername = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlUsername"];
   mCtrlPassword = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlPassword"];
   mCtrlEndPoint = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlEndPoint" target:self action:@selector(onCtrlEndPointClick)];

   [self hideWaitPanel];

   EndPointConfig *cfg = [mCfgMgr getSelectedConfig];
   if (cfg) {

      [mCtrlEndPoint setTitle:[cfg getUrl]];
      if ([UILib initWith:[cfg getUrl] serverApiKey:[cfg getApiKey] ssoAppId:@"jm1ag8bg08" ssoAppSecret:@"1FE10659309B3CF150B479995CC13DA1" httpPlugin:nil callback:[[DgApp getDgInstance] getAppUILibCallback] handler:nil closure:nil]) {
         [self showWaitPanel];
         [self setLocalizedStatusMsg:@"InitVRLib"];
      } else {
         [self setLocalizedStatusMsg:@"Failure"];
      }
   } else {
      [self setLocalizedStatusMsg:@"NoEPConfigured"];
      [mCtrlEndPoint setTitle:NSLocalizedString(@"NoEPConfigured", nil)];
   }

}

- (void)onUnload {
   [super onUnload];
   [AppUtil removeAllSubViews:mCtrlLoginPanel];
   DgApp *dgApp = [DgApp getDgInstance];
   [[dgApp getAppUILibCallback].mSubCallbacks removeObject:self];
}

- (NSTextField *)getStatusMsgCtrl {
   return mCtrlStatusMsg;
}

@end

@implementation FormUILibCallbackLogin {
   CtFormUILibLogin *mForm;
}

- (id)initWith:(CtFormUILibLogin *)form {
   mForm = form;
   return [super init];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   NSLog(@"VR Login failure");
   NSString *msgStr = NSLocalizedString(@"FailureWithStatusCode", nil);
   NSString *withStatus = [NSString stringWithFormat:msgStr, status];
   [mForm setStatusMsg:withStatus];
}

- (void)onSuccess:(Object)closure result:(id)result {
   id<User> user = result;
   NSString *tmpl = NSLocalizedString(@"LoggedInAs", nil);
   NSString *msg = [NSString stringWithFormat:tmpl, [user getName]];
   [mForm setStatusMsg:msg];
   DgApp *dgApp = [DgApp getDgInstance];
   [dgApp setUser:user];
   [dgApp showForm:[CtFormLoggedIn alloc] nibName:@"FormLoggedIn"];
}

- (void)onException: (Object)closure  exception:(Exception)exception {
   
}

- (void)onCancelled:(Object)closure {
   
}

@end


@implementation FormUILibCallbackInit {
   CtFormUILibLogin *mForm;
}

- (id)initWith:(CtFormUILibLogin *)form {
   mForm = form;
   return [super init];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   NSLog(@"VR Init failure");
   [mForm setLocalizedStatusMsg:@"Failure"];
}

- (void)onSuccess:(Object)closure {
   NSLog(@"VR Init success %@", closure);
   [mForm setLocalizedStatusMsg:@"Success"];
}

@end

@implementation FormUILibCallbackDestroy {
   CtFormUILibLogin *mForm;
}

- (id)initWith:(CtFormUILibLogin *)form {
   mForm = form;
   return [super init];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   NSLog(@"VR Destroy failure");
   [mForm setLocalizedStatusMsg:@"Failure"];
}

- (void)onSuccess:(Object)closure {
   NSLog(@"VR Destroy success %@", closure);
   [mForm setLocalizedStatusMsg:@"Success"];
}

@end
