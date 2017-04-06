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

#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>
#import <WebKit/WebDataSource.h>

#import <SDKLib/VR.h>
#import <SDKLib/User.h>

#import "UILibCtFormLogin.h"
#import "UILib.h"
#import "UILibUtil.h"

@interface UILibCallbackInit : NSObject<VR_Result_Init>

- (id)initWith:(UILibCtFormLogin *)form;

@end

@interface UILibCallbackDestroy : NSObject<VR_Result_Destroy>

- (id)initWith:(UILibCtFormLogin *)form;

@end

@interface UILibCallbackLogin : NSObject<VR_Result_Login>

- (id)initWith:(UILibCtFormLogin *)form;

@end

@implementation UILibCtFormLogin {
   NSControl *mCtrlHome, *mCtrlBack, *mCtrlVRLogin;
   NSButton *mCtrlEndPoint, *mCtrlTest;
   NSTextField *mCtrlStatusMsg, *mCtrlUsername, *mCtrlPassword;
   WebView *mCtrlWebView;
   UILibCallbackInit *mCallbackInit;
   UILibCallbackDestroy *mCallbackDestroy;
   UILibCallbackLogin *mCallbackLogin;
}

static const NSString *sLoginUrl = @"https://account.samsung.com/mobile/account/check.do";
static const NSString *sLocalhost = @"localhost";

- (void)toLoginPage {
   NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:sLoginUrl]];
   NSString *requestBody = [NSString stringWithFormat:@"serviceID=%@&actionID=StartOAuth2&redirect_uri=http://%@&accessToken=Y", @"", sLocalhost];

   [request setHTTPMethod:@"POST"];
   [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
   [[mCtrlWebView mainFrame] loadRequest:request];
}

- (void)onCtrlVRLoginClick {

}

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource {
   NSURL *pUrl = [request URL];
   NSLog(@"Loading %@ %@", pUrl, [pUrl host]);
   if ([sLocalhost isEqualToString:[pUrl host]]) {
      NSString *myString = [[NSString alloc] initWithData:[[[mCtrlWebView mainFrame] dataSource] data] encoding:NSUTF8StringEncoding];
      [[sender mainFrame] stopLoading];
      NSLog(@"Data %@", myString);
   }
   return self;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
   //NSString *myString = [[NSString alloc] initWithData:[[frame dataSource] data] encoding:NSUTF8StringEncoding];
   //NSLog(@"Frame data: %@", myString);
}

- (void)onCtrlHomeClick {
   [self toLoginPage];
}

- (void)onCtrlBackClick {
   [mCtrlWebView goBack];
}

- (void)onLoad {
   [super onLoad];

   NSView *root = [self view];
   mCtrlWebView = (WebView *)[UILibUtil findViewById:root identifier:@"ctrlWebView"];
   [mCtrlWebView setResourceLoadDelegate:self];
   [mCtrlWebView setFrameLoadDelegate:self];
   mCtrlVRLogin = [UILibUtil setActionHandler:root identifier:@"ctrlVRLogin" target:self action:@selector(onCtrlVRLoginClick)];
   mCtrlHome = [UILibUtil setActionHandler:root identifier:@"ctrlHome" target:self action:@selector(onCtrlHomeClick)];
   mCtrlBack = [UILibUtil setActionHandler:root identifier:@"ctrlBack" target:self action:@selector(onCtrlBackClick)];
   [self toLoginPage];
}


- (NSTextField *)getStatusMsgCtrl {
   return mCtrlStatusMsg;
}

@end

@implementation UILibCallbackLogin {
   UILibCtFormLogin *mForm;
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
}

- (void)onException: (Object)closure  exception:(Exception)exception {
   
}

- (void)onCancelled:(Object)closure {
   
}


@end


@implementation UILibCallbackInit {
   UILibCtFormLogin *mForm;
}

- (id)initWith:(UILibCtFormLogin *)form {
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

@implementation UILibCallbackDestroy {
   UILibCtFormLogin *mForm;
}

- (id)initWith:(UILibCtFormLogin *)form {
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
