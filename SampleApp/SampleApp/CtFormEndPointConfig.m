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
#import "EndPointConfigManager.h"

@interface CtFormEndPointViewAdapter : NSObject<NSTableViewDataSource>
@end

@implementation CtFormEndPointViewAdapter {
   EndPointConfigManager *mCfgMgr;
}

- (id)init {
   mCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
   return [super init];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
   return [mCfgMgr getCount];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
   NSArray *items = [mCfgMgr getList];
   if (items && row >= 0 && row < [items count]) {
      EndPointConfig *cfg = [items objectAtIndex:row];
      NSString *colId = [tableColumn identifier];
      if ([@"tableColumnURL" isEqualToString:colId]) {
         return [cfg getUrl];
      }
      if ([@"tableColumnAPIKey" isEqualToString:colId]) {
         return [cfg getApiKey];
      }
   }
   return nil;
}

@end

@implementation CtFormEndPointConfig {
   NSControl *mCtrlBack, *mCtrlCfgSelect, *mCtrlCfgLoad;
   NSTextField *mCtrlCfgURL, *mCtrlStatus;
   NSTableView *mCtrlConfigList;
   CtFormEndPointViewAdapter *mEndPointViewAdapter;
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


- (void)updateUI {
   [mCtrlConfigList reloadData];
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
   
   EndPointConfigManager *cfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
   mEndPointViewAdapter = [[CtFormEndPointViewAdapter alloc] init];
   mCtrlBack = [AppUtil setActionHandler:root identifier:@"ctrlBack" target:self action:@selector(onCtrlBackClick)];
   mCtrlCfgSelect = [AppUtil setActionHandler:root identifier:@"ctrlCfgSelect" target:self action:@selector(onCtrlCfgSelectClick)];
   mCtrlCfgURL = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlCfgURL"];
   [mCtrlCfgURL setStringValue:[[cfgMgr getCurrentCfgURL] absoluteString]];
   
   mCtrlCfgLoad = [AppUtil setActionHandler:root identifier:@"ctrlCfgLoad" target:self action:@selector(onCtrlCfgLoadClick)];
   mCtrlConfigList = (NSTableView *)[AppUtil findViewById:root identifier:@"ctrlConfigList"];
   mCtrlConfigList.dataSource = mEndPointViewAdapter;
   mCtrlStatus = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlStatus"];
}

- (void)onUnload {
   [super onUnload];
   mCtrlBack = NULL;
   mCtrlCfgSelect = NULL;
   mCtrlCfgURL = NULL;
   mCtrlCfgLoad = NULL;
   mCtrlConfigList.dataSource = NULL;
   mCtrlConfigList = NULL;
   mCtrlStatus = NULL;
   mEndPointViewAdapter = NULL;
}

@end
