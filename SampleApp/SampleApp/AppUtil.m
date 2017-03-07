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

+ (NSView *)findViewById:(NSView *)root identifier:(NSString *)identifier {
   NSMutableArray *stack = [[NSMutableArray alloc] init];
   NSView *currView = root;
   while (currView) {
      if ([identifier isEqualToString:[currView identifier]]) {
         return currView;
      }
      NSArray *childViews = [currView subviews];
      for (NSView *childView in childViews) {
         if ([identifier isEqualToString:[childView identifier]]) {
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

+ (NSControl *)setActionHandler:(NSView *)root identifier:(NSString *)identifier target:(id)target action:(SEL)action {
   NSControl *found = (NSControl *)[AppUtil findViewById:root identifier:identifier];
   if (found) {
      found.target = target;
      found.action = action;
   }
   return found;
}

@end
