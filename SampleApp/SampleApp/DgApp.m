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
#import "CtFormMain.h"
#import "CtFormLogin.h"

static DgApp *sInstance = NULL;

@implementation DgApp {
   NSArray *mTopLevelNibObjs;
   CtFormMain *mCtFormMain;
   EndPointConfigManager *mEndPointCfgMgr;
   SharedPrefs *mAppPrefs;
   id<User> mUser;
}

- (id)init {
   mTopLevelNibObjs = NULL;
   mCtFormMain = NULL;
   mAppPrefs = [[SharedPrefs alloc] initWithName:@"AppPrefs"];
   mEndPointCfgMgr = [[EndPointConfigManager alloc] initWithApp:self];
   
   return [super init];
}

- (SharedPrefs *)getAppPrefs {
   return mAppPrefs;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   mCtFormMain = [[CtFormMain alloc] initWithWindowNibName:@"FormMain"];
   [mCtFormMain showWindow:nil];
}

- (bool)showForm:(CtForm *)form {
   if (!mCtFormMain) {
      return false;
   }
   [mCtFormMain setForm:form];
   return true;
}

- (bool)showForm:(CtForm *)form nibName:(NSString *)nibName {
   CtForm *result = [form initWithNibName:nibName bundle:nil];
   return [self showForm:result];
}

- (bool)showLoginForm {
   return [self showForm:[[CtFormLogin alloc] initWithNibName:@"FormLogin" bundle:nil]];
}

- (void)onMainFormClosed {
   [NSApp terminate:nil];
}

- (EndPointConfigManager *)getEndPointCfgMgr {
   return mEndPointCfgMgr;
}

- (void)setUser:(id<User>)user {
   mUser = user;
}

- (id<User>)getUser {
   return mUser;
}

+ (DgApp *)getDgInstance {
   if (!sInstance) {
      sInstance = [[DgApp alloc] init];
   }
   return sInstance;
}



@end
