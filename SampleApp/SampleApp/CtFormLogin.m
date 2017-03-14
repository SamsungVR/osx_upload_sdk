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
#import "CtFormLogin.h"
#import "CtFormEndPointConfig.h"
#import "CtFormLoggedIn.h"
#import "AppUtil.h"

#import <SDKLib/VR.h>
#import <SDKLib/User.h>

@interface CallbackInit : NSObject<VR_Result_Init>

- (id)initWith:(CtFormLogin *)form;

@end

@interface CallbackDestroy : NSObject<VR_Result_Destroy>

- (id)initWith:(CtFormLogin *)form;

@end

@interface CallbackLogin : NSObject<VR_Result_Login>

- (id)initWith:(CtFormLogin *)form;

@end


@implementation CtFormLogin {
   NSControl *mCtrlLogin;
   NSButton *mCtrlEndPoint;
   NSTextField *mCtrlStatusMsg, *mCtrlUsername, *mCtrlPassword;
   EndPointConfigManager *mCfgMgr;
   CallbackInit *mCallbackInit;
   CallbackDestroy *mCallbackDestroy;
   CallbackLogin *mCallbackLogin;
}

- (void)onCtrlEndPointClick {
   [[DgApp getDgInstance] showForm:[CtFormEndPointConfig alloc] nibName:@"FormEndPointConfig"];
}

- (void)onCtrlLoginClick {
   [VR login:[mCtrlUsername stringValue] password:[mCtrlPassword stringValue]
     callback:mCallbackLogin handler:nil closure:nil];
}


- (void)initVRLib {
   EndPointConfig *cfg = [mCfgMgr getSelectedConfig];
   if (cfg) {

      [mCtrlEndPoint setTitle:[cfg getUrl]];
      if ([VR destroyAsync:mCallbackDestroy handler:nil closure:nil]) {
         [self setLocalizedStatusMsg:@"DestroyVRLib"];
      } else {
         if ([VR initAsync:[cfg getUrl] apiKey:[cfg getApiKey] callback:mCallbackInit handler:nil closure:nil]) {
            [self setLocalizedStatusMsg:@"InitVRLib"];
         } else {
            [self setLocalizedStatusMsg:@"Failure"];
         }
      }
   } else {
      [self setLocalizedStatusMsg:@"NoEPConfigured"];
      [mCtrlEndPoint setTitle:NSLocalizedString(@"NoEPConfigured", nil)];
   }
   
}

- (void)onLoad {
   [super onLoad];

   DgApp *dgApp = [DgApp getDgInstance];
   [dgApp setUser:nil];
   mCfgMgr = [dgApp getEndPointCfgMgr];
   mCallbackInit = [[CallbackInit alloc] initWith:self];
   mCallbackDestroy = [[CallbackDestroy alloc] initWith:self];
   mCallbackLogin = [[CallbackLogin alloc] initWith:self];
   
   NSView *root = [self view];
   mCtrlLogin = [AppUtil setActionHandler:root identifier:@"ctrlLogin" target:self action:@selector(onCtrlLoginClick)];
   mCtrlStatusMsg = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlStatusMsg"];
   mCtrlUsername = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlUsername"];
   mCtrlPassword = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlPassword"];
   mCtrlEndPoint = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlEndPoint" target:self action:@selector(onCtrlEndPointClick)];
   [self initVRLib];
}

@end

@implementation CallbackLogin {
   CtFormLogin *mForm;
}

- (id)initWith:(CtFormLogin *)form {
   mForm = form;
   return [super init];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   NSLog(@"VR Login failure");
   [mForm setLocalizedStatusMsg:@"Failure"];
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


@implementation CallbackInit {
   CtFormLogin *mForm;
}

- (id)initWith:(CtFormLogin *)form {
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

@implementation CallbackDestroy {
   CtFormLogin *mForm;
}

- (id)initWith:(CtFormLogin *)form {
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
   [mForm initVRLib];
   
}

@end
