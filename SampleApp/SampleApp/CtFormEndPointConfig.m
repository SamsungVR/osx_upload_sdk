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

#import "CtFormEndPointConfig.h"
#import "AppUtil.h"
#import "DgApp.h"
#import "CtFormLogin.h"

@implementation CtFormEndPointConfig {
   NSControl *mCtrlBack, *mCtrlCfgSelect, *mCtrlCfgLoad;
   NSTextField *mCtrlCfgURL, *mCtrlStatus;
   NSStackView *mCtrlConfigList;
}

- (void)onCtrlBackClick {
   if (![self isLoaded]) {
      return;
   }
   [[DgApp getDgInstance] showForm:[CtFormLogin alloc] nibName:@"FormLogin"];
}

- (void)onCtrlCfgSelectClick {
   if (![self isLoaded]) {
      return;
   }
   
   NSURL *pResult = [AppUtil showFileOpenOrSaveDialog];
   if (pResult) {
      [mCtrlCfgURL setStringValue:[pResult absoluteString]];
   }
}

- (NSView *)setEndPointCfgOnForm:(NSView *)root epCfg:(EndPointConfig *)epCfg {
   NSTextField *url = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlUrl"];
   NSTextField *apiKey = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlAPIKey"];
   [url setStringValue:[epCfg getUrl]];
   [apiKey setStringValue:[epCfg getApiKey]];
   return root;
}

- (void)updateUI {
   EndPointConfigManager *pCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
   
   [AppUtil removeAllSubViews:mCtrlConfigList];
   EndPointConfig *selected = [pCfgMgr getSelectedConfig];
   NSArray *endPoints = [pCfgMgr getList];
   NSUInteger len = [endPoints count];
   for (int i = 0; i < len; i += 1) {
      EndPointConfig *epCfg = [endPoints objectAtIndex:i];
      NSView *view = [[[NSViewController alloc] initWithNibName:@"FormEndPointConfigItem" bundle:nil] view];
      [self setEndPointCfgOnForm:view epCfg:epCfg];
      [mCtrlConfigList addView:view inGravity:NSStackViewGravityCenter];
   }
}

- (void)onCtrlCfgLoadClick {
   if (![self isLoaded]) {
      return;
   }
   NSURL *pCfgUrl = [NSURL URLWithString:[mCtrlCfgURL stringValue]];
   EndPointConfigManager *pCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
   if ([pCfgMgr loadJsonConfig:pCfgUrl]) {
      [mCtrlStatus setStringValue:NSLocalizedString(@"Success", nil)];
   } else {
      [mCtrlStatus setStringValue:NSLocalizedString(@"Failure", nil)];
   }
   [self updateUI];
}

- (void)onLoad {
   [super onLoad];
   NSView *root = [self view];
   mCtrlBack = [AppUtil setActionHandler:root identifier:@"ctrlBack" target:self action:@selector(onCtrlBackClick)];
   mCtrlCfgSelect = [AppUtil setActionHandler:root identifier:@"ctrlCfgSelect" target:self action:@selector(onCtrlCfgSelectClick)];
   mCtrlCfgURL = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlCfgURL"];
   mCtrlCfgLoad = [AppUtil setActionHandler:root identifier:@"ctrlCfgLoad" target:self action:@selector(onCtrlCfgLoadClick)];
   mCtrlConfigList = (NSStackView *)[AppUtil findViewById:root identifier:@"ctrlConfigList"];
   mCtrlStatus = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlStatus"];
}

- (void)onUnload {
   [super onUnload];
   mCtrlBack = NULL;
   mCtrlCfgSelect = NULL;
   mCtrlCfgURL = NULL;
   mCtrlCfgLoad = NULL;
   mCtrlConfigList = NULL;
   mCtrlStatus = NULL;
}

@end
