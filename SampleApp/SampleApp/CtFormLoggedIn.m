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
#import "CtFormCreateLiveEvent.h"
#import "AppUtil.h"
#import "DgApp.h"

@implementation CtFormLoggedIn {
   NSImageView *mCtrlProfilePic;
   NSTextField *mCtrlUsername, *mCtrlUserEmail;
   NSBox *mCtrlSubContainer;
   
   NSButton *mCtrlCreateLiveEvent;
   
   
   CtForm *mSubForm;
   id<User> mUser;
}

- (void)onUnload {
   [self unloadCurrentSubForm];
   [super onUnload];
}

- (void)setSubForm:(CtForm *)subForm {
   if (mSubForm && subForm && [mSubForm class] == [subForm class]) {
      return;
   }
   
   [self unloadCurrentSubForm];
   
   mSubForm = subForm;
   if (mSubForm) {
      NSView *subView = [mSubForm view];
      if (subView) {
         [mCtrlSubContainer addSubview:subView];
         NSSize subViewSize = subView.frame.size;
         NSSize containerViewSize = mCtrlSubContainer.frame.size;
         
         int dx = containerViewSize.width - subViewSize.width;
         int dy = containerViewSize.height - subViewSize.height;
         
         NSPoint currentLoc;
         currentLoc.x = dx / 2;
         currentLoc.y = dy / 2;
         [subView setFrameOrigin:currentLoc];
         [mSubForm onLoad];
      }
   }
}
- (void)setSubForm:(CtForm *)form nibName:(NSString *)nibName {
   CtForm *result = [form initWithNibName:nibName bundle:nil];
   [self setSubForm:result];
}

- (void)onCtrlCreateLiveEventClick {
   [self setSubForm:[CtFormCreateLiveEvent alloc] nibName:@"FormCreateLiveEvent"];
}

- (void)onLoad {
   [super onLoad];
  
   mUser = [[DgApp getDgInstance] getUser];
   NSView *root = [self view];
   
   mCtrlProfilePic = (NSImageView *)[AppUtil findViewById:root identifier:@"ctrlUserProfilePic"];
   mCtrlUserEmail = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlUserEmail"];
   mCtrlUsername = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlUsername"];
   mCtrlSubContainer = (NSBox *)[AppUtil findViewById:root identifier:@"ctrlSubContainer"];
   
   NSURL *profilePicUrl = [mUser getProfilePicUrl];
   NSImage *img = [[NSImage alloc] initWithContentsOfURL:profilePicUrl];
   [mCtrlProfilePic setImage:img];
   
   [mCtrlUsername setStringValue:[mUser getName]];
   [mCtrlUserEmail setStringValue:[mUser getEmail]];
   
   mCtrlCreateLiveEvent = (NSButton*)[AppUtil setActionHandler:root identifier:@"ctrlCreateLiveEvent" target:self action:@selector(onCtrlCreateLiveEventClick)];
}

- (bool)unloadCurrentSubForm {
   bool result = false;
   
   if (mSubForm) {
      [mSubForm onUnload];
      
      NSView *subView = [mSubForm view];
      if (subView) {
         [subView removeFromSuperview];
         result = true;
      }
      mSubForm = NULL;
   }
   return result;
}




@end
