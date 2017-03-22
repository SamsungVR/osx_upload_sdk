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
#import "CtForm.h"
#import "AppUtil.h"
#import "DgApp.h"

@implementation CtFormMain {
    CtForm *mForm;
}

- (void)dismissKeyboard {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)viewDidLoad {
   [super viewDidLoad];
   DgApp *dgApp = [DgApp getDgInstance];
   [dgApp setCtFormMain:self];

   UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
   [self.view addGestureRecognizer:singleFingerTap];
   [dgApp showLoginForm];
}

- (void)updateSubviewSize:(CGSize)mySize {
    if (mForm) {
        UIView *subView = [mForm view];
        if (subView) {
            CGSize controlSize = subView.frame.size;
            NSLog(@"Control size %@ %f %f", subView, controlSize.width, controlSize.height);
            int dx = mySize.width - controlSize.width;
            //int dy = mySize.height - controlSize.height;
            CGRect newRect = CGRectMake(dx / 2.0, 10.0, controlSize.width, controlSize.height);
            [subView setFrame:newRect];
        }
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateSubviewSize:size];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateSubviewSize:self.view.frame.size];
}

- (bool)unloadCurrentForm {
    bool result = false;
    
    if (mForm) {
        [mForm onUnload];
        
        UIView *subView = [mForm view];
        if (subView) {
            [subView removeFromSuperview];
            result = true;
        }
        mForm = NULL;
    }
    return result;
}

- (void)setForm:(CtForm *)form {
    
    [self unloadCurrentForm];
    
    mForm = form;
    if (mForm) {
        UIView *subView = [mForm view];
        if (subView) {
            [[self view] addSubview:subView];
            [mForm onLoad];
        }
    }
}

@end
