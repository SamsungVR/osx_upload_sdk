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


#import "SDKLib/User.h"

#import "CtFormLoggedIn.h"
#import "AppUtil.h"
#import "DgApp.h"

@implementation CtFormLoggedIn {
   NSImageView *mCtrlProfilePic;
   NSTextField *mCtrlUsername, *mCtrlUserEmail;
   
   id<User> mUser;
}

- (void)onLoad {
   [super onLoad];
  
   mUser = [[DgApp getDgInstance] getUser];
   NSView *root = [self view];
   
   mCtrlProfilePic = (NSImageView *)[AppUtil findViewById:root identifier:@"ctrlUserProfilePic"];
   mCtrlUserEmail = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlUserEmail"];
   mCtrlUsername = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlUsername"];
   
   NSURL *profilePicUrl = [mUser getProfilePicUrl];
   NSImage *img = [[NSImage alloc] initWithContentsOfURL:profilePicUrl];
   [mCtrlProfilePic setImage:img];
   
   [mCtrlUsername setStringValue:[mUser getName]];
   [mCtrlUserEmail setStringValue:[mUser getEmail]];
   
   //[AppUtil setActionHandler:root identifier:@"ctrlLogin" target:self action:@selector(onCtrlLoginClick)];
}

@end
