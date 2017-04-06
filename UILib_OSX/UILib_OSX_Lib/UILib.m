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

#import "UILib.h"
#import "UILibCtFormLogin.h"

#import <Cocoa/Cocoa.h>

@implementation UILib

static NSWindow *mTemp;
static NSWindowController *mTemp2;
static UILibCtFormLogin *mFormLogin;

+ (void)initialize {

}

+ (void)test {
    NSRect contentSize = NSMakeRect(500.0, 500.0, 1000.0, 1000.0);
    NSUInteger windowStyleMask = NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask;
    mTemp = [[NSWindow alloc] initWithContentRect:contentSize styleMask:windowStyleMask backing:NSBackingStoreBuffered defer:YES];

    mTemp2 = [[NSWindowController alloc] initWithWindow:mTemp];
    [mTemp2 showWindow:nil];

    NSBundle *bundle = [NSBundle bundleWithPath:@"Res.bundle"];

    //bundle = [NSBundle mainBundle];
    mFormLogin = [[UILibCtFormLogin alloc] initWithNibName:@"UILibFormLogin" bundle:bundle];
    NSView *subView = [mFormLogin view];
    NSLog(@"subView: %f %f", subView.frame.size.width, subView.frame.size.height);
    if (subView) {
        NSSize controlSize = subView.frame.size;
        NSWindow *window = [mTemp2 window];
        [window setContentSize:controlSize];
        [[window contentView] addSubview:subView];
        [mFormLogin onLoad];
    }
}

@end
