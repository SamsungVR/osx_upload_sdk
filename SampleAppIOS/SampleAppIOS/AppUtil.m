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

#import "AppUtil.h"

@implementation AppUtil

+ (UIView *)findViewById:(UIView *)root identifier:(NSString *)identifier {
   NSMutableArray *stack = [[NSMutableArray alloc] init];
   UIView *currView = root;
   while (currView) {
      if ([identifier isEqualToString:[currView restorationIdentifier]]) {
         return currView;
      }
      NSArray *childViews = [currView subviews];
      for (UIView *childView in childViews) {
         if ([identifier isEqualToString:[childView restorationIdentifier]]) {
            return childView;
         }
         [stack addObject:childView];
      }
      if ([stack count] > 0) {
         currView = [stack objectAtIndex:0];
         [stack removeObjectAtIndex:0];
      } else {
         currView = nil;
      }
   }
   return nil;
}

+ (void)setEnabled:(UIView *)root enabled:(bool)enabled {
   NSMutableArray *stack = [[NSMutableArray alloc] init];
   UIView *currView = root;
   while (currView) {
      if ([currView respondsToSelector:@selector(setEnabled:)]) {
         [((UIControl *)currView) setEnabled:enabled];
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

+ (UIControl *)setActionHandler:(UIView *)root identifier:(NSString *)identifier target:(id)target action:(SEL)action {
   UIControl *found = (UIControl *)[AppUtil findViewById:root identifier:identifier];
   if (found) {
      [found addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
   }
   return found;
}

+ (NSURL *)showFileOpenOrSaveDialog {
   return NULL;
}


+ (void)removeAllSubViews:(UIView *)view {
   do {
      NSArray *subViews = [view subviews];
      if ([subViews count] < 1) {
         return;
      }
      [[subViews objectAtIndex:0] removeFromSuperview];
   }
   while (true);
}

@end
