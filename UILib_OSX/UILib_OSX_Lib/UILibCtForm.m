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

#import "UILibCtForm.h"


@implementation UILibCtForm {
   bool mIsLoaded;
   NSBundle *mBundle;
}

- (void)onLoad {
   mIsLoaded = true;
}

- (void)onUnload {
   mIsLoaded = false;
}

- (bool)isLoaded {
   return mIsLoaded;
}

- (id)initWith:(NSString *)xibName bundle:(NSBundle *)bundle {
   mBundle = bundle;
   return [super initWithNibName:xibName bundle:bundle];
}

- (NSBundle *)getBundle {
   return mBundle;
}

- (void)setLocalizedStatusMsg:(NSString *)msg {
   if ([self isLoaded]) {
      NSTextField *statusCtrl = [self getStatusMsgCtrl];
      if (statusCtrl) {
         NSString *realMsg = NSLocalizedStringFromTableInBundle(msg, @"Localizable", mBundle, nil);
         [statusCtrl setStringValue:realMsg];
      }
   }
}

- (void)setStatusMsg:(NSString *)msg {
   if ([self isLoaded]) {
      NSTextField *statusCtrl = [self getStatusMsgCtrl];
      if (statusCtrl) {
         [statusCtrl setStringValue:msg];
      }
   }
}

- (NSTextField *)getStatusMsgCtrl {
   return nil;
}

@end
