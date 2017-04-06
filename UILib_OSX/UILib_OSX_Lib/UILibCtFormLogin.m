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
#import <WebKit/DOMHtmlCollection.h>
#import <WebKit/DOMDocument.h>
#import <WebKit/DOMHTMLElement.h>
#import <WebKit/DOMNodeList.h>
#import <WebKit/DOMNamedNodeMap.h>

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

@interface UILibCallbackSSOLogin : NSObject<VR_Result_LoginSSO>

- (id)initWith:(UILibCtFormLogin *)form;

@end

@implementation UILibCtFormLogin {
   NSControl *mCtrlHome, *mCtrlBack, *mCtrlVRLogin;
   NSButton *mCtrlEndPoint, *mCtrlTest;
   NSTextField *mCtrlLoginStatus, *mCtrlVRUsername, *mCtrlVRPassword;
   NSProgressIndicator *mCtrlSSOProgress;
   WebView *mCtrlWebView;
   UILibCallbackInit *mCallbackInit;
   UILibCallbackDestroy *mCallbackDestroy;
   UILibCallbackLogin *mCallbackLogin;
   UILibCallbackSSOLogin *mCallbackSSOLogin;
}

static const NSString *sLoginUrl = @"https://account.samsung.com/mobile/account/check.do";
static const NSString *sLocalhost = @"localhost";

- (void)showSSOLoginProgress {
   [mCtrlWebView setHidden:YES];
   [mCtrlSSOProgress setHidden:NO];
   [mCtrlSSOProgress startAnimation:nil];
}

- (void)hideSSOLoginProgress {
   [mCtrlSSOProgress stopAnimation:nil];

   [mCtrlWebView setHidden:NO];
   [mCtrlSSOProgress setHidden:YES];
}

- (void)toLoginPage {
   [self showSSOLoginProgress];
   [mCtrlVRPassword setStringValue:@""];
   [mCtrlLoginStatus setStringValue:@""];

   NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:sLoginUrl]];
   NSString *requestBody = [NSString stringWithFormat:@"serviceID=%@&actionID=StartOAuth2&redirect_uri=http://%@&accessToken=Y", @"jm1ag8bg08", sLocalhost];

   [request setHTTPMethod:@"POST"];
   [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
   [[mCtrlWebView mainFrame] loadRequest:request];
}

- (void)onCtrlVRLoginClick {

}

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource {
   NSURL *url = [request URL];
   if ([sLocalhost isEqualToString:[url host]]) {
      WebFrame *frame = [mCtrlWebView mainFrame];
      [frame stopLoading];

      NSString *htmlStr = [[NSString alloc] initWithData:[[[mCtrlWebView mainFrame] dataSource] data] encoding:NSUTF8StringEncoding];
      //NSLog(@"Html %@", htmlStr);
      DOMDocument *document = [frame DOMDocument];
      DOMNodeList *inputs = [document getElementsByName:@"code"];
      //DOMNodeList *inputs = [document getElementsByTagName:@"input"];
      if (inputs && 1 == [inputs length]) {
         DOMNode *input = [inputs item:0];
         DOMNamedNodeMap *attributes = [input attributes];
         /*
         for (int i = [attributes length]; i >= 0; i -= 1) {
            DOMNode *attr = [attributes item:i];
            NSLog(@"%@ %@", [attr nodeName], [attr nodeValue]);
         }
         */
         DOMNode *valueNode = [attributes getNamedItem:@"value"];
         if (valueNode) {
            NSString *value = [valueNode nodeValue];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if (json) {
               /*
                {
                "access_token": "kjdkdkdjdl",
                "token_type": "bearer",
                "access_token_expires_in": 530184,
                "refresh_token": "-1",
                "refresh_token_expires_in": -1,
                "userId": "hkjkjkkuih",
                "client_id": "uhjnjujj3k",
                "api_server_url": "us-auth2.samsungosp.com",
                "auth_server_url": "us-auth2.samsungosp.com",
                "inputEmailID": "venkat230278+0@gmail.com"
                }
                */
               NSString *accessToken = [UILibUtil jsonOptObj:json key:@"access_token" def:nil];
               NSString *authServerUrl = [UILibUtil jsonOptObj:json key:@"auth_server_url" def:nil];
               if (accessToken && authServerUrl) {
                  NSLog(@"Access token %@ Url %@", accessToken, authServerUrl);
                  if ([VR loginSamsungAccount:accessToken auth_server:authServerUrl callback:mCallbackSSOLogin handler:nil closure:nil]) {
                     [self showSSOLoginProgress];
                     return self;
                  }
               }
            }

         }
      }
      [self toLoginPage];
   }
   return self;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
   //NSString *myString = [[NSString alloc] initWithData:[[frame dataSource] data] encoding:NSUTF8StringEncoding];
   //NSLog(@"Frame data: %@", myString);
   [self hideSSOLoginProgress];
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
   mCallbackSSOLogin = [[UILibCallbackSSOLogin alloc] initWith:self];
   mCtrlWebView = (WebView *)[UILibUtil findViewById:root identifier:@"ctrlWebView"];
   mCtrlSSOProgress = (NSProgressIndicator *)[UILibUtil findViewById:root identifier:@"ctrlSSOProgress"];
   mCtrlLoginStatus = (NSTextField *)[UILibUtil findViewById:root identifier:@"ctrlLoginStatus"];

   [mCtrlWebView setResourceLoadDelegate:self];
   [mCtrlWebView setFrameLoadDelegate:self];
   mCtrlVRLogin = [UILibUtil setActionHandler:root identifier:@"ctrlVRLogin" target:self action:@selector(onCtrlVRLoginClick)];
   mCtrlHome = [UILibUtil setActionHandler:root identifier:@"ctrlHome" target:self action:@selector(onCtrlHomeClick)];
   mCtrlBack = [UILibUtil setActionHandler:root identifier:@"ctrlBack" target:self action:@selector(onCtrlBackClick)];

   [self toLoginPage];
}


- (NSTextField *)getStatusMsgCtrl {
   return mCtrlLoginStatus;
}

@end

@implementation UILibCallbackLogin {
   UILibCtFormLogin *mForm;
}

- (id)initWith:(UILibCtFormLogin *)form {
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
}

- (void)onException: (Object)closure  exception:(Exception)exception {
   
}

- (void)onCancelled:(Object)closure {
   
}


@end

@implementation UILibCallbackSSOLogin {
   UILibCtFormLogin *mForm;
}

- (id)initWith:(UILibCtFormLogin *)form {
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
