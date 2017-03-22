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

#import "CtForm.h"


@implementation CtForm {
   bool mIsLoaded;
   NSMutableArray *mTabOrder;
}

- (void)setupTabOrder {
   mTabOrder = [[NSMutableArray alloc] init];
   NSMutableArray *stack = [[NSMutableArray alloc] init];
   UIView *currView = self.view;
   while (currView) {
      if ([currView isKindOfClass:[UITextField class]]) {
         [mTabOrder addObject:currView];
         [((UITextField *)currView) setDelegate:self];
      }
      NSArray *childViews = [currView subviews];
      for (UIView *childView in childViews) {
         [stack addObject:childView];
      }
      if ([stack count] > 0) {
         currView = [stack objectAtIndex:0];
         [stack removeObjectAtIndex:0];
      } else {
         currView = nil;
      }
   }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   BOOL didResign = [textField resignFirstResponder];
   if (!didResign) {
      return NO;
   }

   int index = [mTabOrder indexOfObject:textField];
   if (NSNotFound == index) {
      return NO;
   }
   int next = index + 1;
   if (next >= [mTabOrder count]) {
      next = 0;
   }
   [[mTabOrder objectAtIndex:next] becomeFirstResponder];
   return NO;
}

- (void)onLoad {
   mIsLoaded = true;
   [self setupTabOrder];

}

- (void)onUnload {
   mIsLoaded = false;
}

- (bool)isLoaded {
   return mIsLoaded;
}

- (void)setLocalizedStatusMsg:(NSString *)msg {
   if ([self isLoaded]) {
      UITextField *statusCtrl = [self getStatusMsgCtrl];
      if (statusCtrl) {
         NSString *realMsg = NSLocalizedString(msg, nil);
         [statusCtrl setText:realMsg];
      }
   }
}

- (void)setStatusMsg:(NSString *)msg {
   if ([self isLoaded]) {
      UITextField *statusCtrl = [self getStatusMsgCtrl];
      if (statusCtrl) {
         [statusCtrl setText:msg];
      }
   }
}

- (UITextField *)getStatusMsgCtrl {
   return nil;
}

@end
