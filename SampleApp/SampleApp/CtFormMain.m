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

#import "CtFormMain.h"
#import "CtFormLogin.h"
#import "DgApp.h"

@implementation CtFormMain {
   CtForm *mForm;
   NSWindow *mMainWindow;
}

- (void)windowDidLoad {
   mMainWindow = [self window];
   [mMainWindow setDelegate:self];
   [self setForm:[[CtFormLogin alloc] initWithNibName:@"FormLogin" bundle:nil]];
}

- (bool)unloadCurrentForm:(NSSize *)size {
   bool result = false;
   
   if (mForm) {
      [mForm onUnload];
      
      NSView *subView = [mForm view];
      if (subView) {
         if (size) {
            *size = subView.frame.size;
         }
         [subView removeFromSuperview];
         result = true;
      }
      mForm = NULL;
   }
   return result;
}

- (void)windowWillClose:(NSNotification *)notification {
   [self unloadCurrentForm:nil];
   [[DgApp getDgInstance] onMainFormClosed];
}

- (void)setForm:(CtForm *)form {
   NSSize prevSize;
   
   bool hadEarlierForm = [self unloadCurrentForm:&prevSize];
   
   mForm = form;
   if (mMainWindow && mForm) {
      NSView *subView = [mForm view];
      if (subView) {
         [[mMainWindow contentView] addSubview:subView];
         NSSize controlSize = subView.frame.size;
         NSLog(@"Control size %@ %f %f", subView, controlSize.width, controlSize.height);
         [mMainWindow setContentSize:controlSize];
         if (hadEarlierForm) {
            NSPoint currentLoc = mMainWindow.frame.origin;
            int dx = prevSize.width - controlSize.width;
            int dy = prevSize.height - controlSize.height;
            currentLoc.x += dx / 2;
            currentLoc.y += dy / 2;
            [mMainWindow setFrameOrigin:currentLoc];
         }
         [mForm onLoad];
      }
   }
}

@end
