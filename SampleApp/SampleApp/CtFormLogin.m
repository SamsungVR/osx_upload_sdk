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
#import "AppUtil.h"
#import <SDKLib/VR.h>

@interface CallbackInit : NSObject<VR_Result_Init>

- (id)initWith:(CtFormLogin *)form;

@end


@interface CallbackDestroy : NSObject<VR_Result_Destroy>

- (id)initWith:(CtFormLogin *)form;

@end



@implementation CtFormLogin {
   NSControl *mCtrlLogin;
   NSButton *mCtrlEndPoint;
   NSTextField *mCtrlStatusMsg;
   EndPointConfigManager *mCfgMgr;
   CallbackInit *mCallbackInit;
   CallbackDestroy *mCallbackDestroy;
}

- (void)onCtrlEndPointClick {
   [[DgApp getDgInstance] showForm:[CtFormEndPointConfig alloc] nibName:@"FormEndPointConfig"];
}

- (void)onCtrlLoginClick {
   
}

- (void)setLocalizedStatusMsg:(NSString *)msg {
   if ([self isLoaded]) {
      NSString *realMsg = NSLocalizedString(msg, nil);
      [mCtrlStatusMsg setStringValue:realMsg];
   }
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

   mCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
   mCallbackInit = [[CallbackInit alloc] initWith:self];
   mCallbackDestroy = [[CallbackDestroy alloc] initWith:self];
   
   NSView *root = [self view];
   mCtrlLogin = [AppUtil setActionHandler:root identifier:@"ctrlLogin" target:self action:@selector(onCtrlLoginClick)];
   mCtrlStatusMsg = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlStatusMsg"];

   mCtrlEndPoint = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlEndPoint" target:self action:@selector(onCtrlEndPointClick)];
   [self initVRLib];
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
