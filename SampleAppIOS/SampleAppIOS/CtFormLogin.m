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

#import "CtFormLogin.h"
#import "DgApp.h"
#import "AppUtil.h"
#import "CtFormEndPointConfig.h"

@implementation CtFormLogin {
   UIControl *mCtrlLogin, *mCtrlEndPoint;
   UITextField *mCtrlStatusMsg, *mCtrlUsername, *mCtrlPassword;


}

- (void)onCtrlLoginClick {

}

- (void)onCtrlEndPointClick {
   [[DgApp getDgInstance] showForm:[CtFormEndPointConfig alloc] nibName:@"FormEndPointConfig"];
}

- (void)onLoad {
   [super onLoad];
   DgApp *dgApp = [DgApp getDgInstance];
   [dgApp setUser:nil];

   UIView *root = [self view];
   mCtrlLogin = [AppUtil setActionHandler:root identifier:@"ctrlLogin" target:self action:@selector(onCtrlLoginClick)];
   mCtrlStatusMsg = (UITextField *)[AppUtil findViewById:root identifier:@"ctrlStatusMsg"];
   mCtrlUsername = (UITextField *)[AppUtil findViewById:root identifier:@"ctrlUsername"];
   mCtrlPassword = (UITextField *)[AppUtil findViewById:root identifier:@"ctrlPassword"];
   mCtrlEndPoint = (UIButton *)[AppUtil setActionHandler:root identifier:@"ctrlEndPoint" target:self action:@selector(onCtrlEndPointClick)];
}

@end
