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

#import "UILibUtil.h"

@implementation UILibUtil

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

+ (void)setEnabled:(NSView *)root enabled:(bool)enabled {
   NSMutableArray *stack = [[NSMutableArray alloc] init];
   NSView *currView = root;
   while (currView) {
      [[currView window] setAcceptsMouseMovedEvents:enabled];
      if ([currView respondsToSelector:@selector(setEnabled:)]) {
         [((NSControl *)currView) setEnabled:enabled];
      }
      NSArray *childViews = [currView subviews];
      for (NSView *childView in childViews) {
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

+ (NSControl *)setActionHandler:(NSView *)root identifier:(NSString *)identifier target:(id)target action:(SEL)action {
   NSControl *found = (NSControl *)[UILibUtil findViewById:root identifier:identifier];
   if (found) {
      found.target = target;
      found.action = action;
   }
   return found;
}

+ (void)removeAllSubViews:(NSView *)view {
   do {
      NSArray *subViews = [view subviews];
      if ([subViews count] < 1) {
         return;
      }
      [[subViews objectAtIndex:0] removeFromSuperview];
   }
   while (true);
}

+ (id)jsonOptObj:(NSDictionary *)jsonObject key:(NSString *)key def:(id)def {
   id result = jsonObject[key];
   return (result) ? result : def;
}

+ (NSInteger)jsonOptInt:(NSDictionary *)jsonObject key:(NSString *)key def:(NSInteger)def {
   NSInteger result = (NSInteger)jsonObject[key];
   if (!result) {
      result = def;
   }
   return result;
}

@end
