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

#import "DgMainWindow.h"

@implementation DgMainWindow {
   NSViewController *mSubViewController;
   NSWindow *mMainWindow;
}

- (id)init {
   mSubViewController = NULL;
   return [super init];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
   mMainWindow = notification.object;
   [self setSubViewController:mSubViewController];
   NSLog(@"windowDidBecomeMain %@", mMainWindow);
}

- (void)windowWillClose:(NSNotification *)notification {
   NSLog(@"windowWillClose %@", mMainWindow);
   [NSApp terminate:nil];
}

- (void)setSubViewController:(NSViewController *)subViewController {
   if (mSubViewController) {
      NSView *subView = [mSubViewController view];
      if (subView) {
         [subView removeFromSuperview];
      }
   }
   mSubViewController = subViewController;
   if (mMainWindow && mSubViewController) {
      NSView *subView = [mSubViewController view];
      if (subView) {
         [[mMainWindow contentView] addSubview:subView];
         NSSize controlSize = subView.frame.size;
         NSLog(@"Control size %@ %f %f", subView, controlSize.width, controlSize.height);
         [mMainWindow setContentSize:controlSize];
      }
   }
}

@end
