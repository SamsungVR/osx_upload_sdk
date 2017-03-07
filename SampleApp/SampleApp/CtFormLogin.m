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

@end

@implementation CallbackInit

- (void)onFailure:(Object)closure status:(NSInteger)status {
   NSLog(@"VR Init failure");
}

- (void)onSuccess:(Object)closure {
   NSLog(@"VR Init success %@", closure);
}

@end

@implementation CtFormLogin {
   NSControl *mCtrlLogin, *mCtrlEndPoint;
   CallbackInit *mCallbackInit;
}

- (void)onCtrlEndPointClick {
   [[DgApp getDgInstance] showForm:[CtFormEndPointConfig alloc] nibName:@"FormEndPointConfig"];
}

- (void)onCtrlLoginClick {
   [VR initAsync:@"https://stage.milkvr.com/api" apiKey:@"5870120fe38ac0000c71d239.X_LgDNKfRz9pmP1XYo_5Y5UCjR2ooFwu6b63M5aZmQc"
        callback:mCallbackInit handler:nil closure:nil];
}

- (void)onLoad {
   [super onLoad];

   mCallbackInit = [[CallbackInit alloc] init];
   NSView *root = [self view];
   mCtrlLogin = [AppUtil setActionHandler:root identifier:@"ctrlLogin" target:self action:@selector(onCtrlLoginClick)];
   mCtrlEndPoint = [AppUtil setActionHandler:root identifier:@"ctrlEndPoint" target:self action:@selector(onCtrlEndPointClick)];

}

- (void)onUnload {
   [super onUnload];
   mCallbackInit = NULL;
   mCtrlLogin = NULL;
}



@end
