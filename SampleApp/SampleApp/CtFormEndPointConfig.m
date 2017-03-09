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



@implementation CtFormEndPointConfig {
   NSControl *mCtrlBack, *mCtrlCfgSelect, *mCtrlCfgLoad, *mCtrlCfgSave,
      *mCtrlCfgDelete, *mCtrlCfgAdd, *mCtrlCfgEdit;
   NSTextField *mCtrlCfgURL, *mCtrlStatus, *mCtrlEditCfgURL, *mCtrlEditCfgAPIKey;
   NSTableView *mCtrlConfigList;
   EndPointConfigManager *mCfgMgr;
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
   [self updateEditZone];
   NSInteger selectedIndex = [mCfgMgr getSelectedIndex];
   if (selectedIndex != [mCtrlConfigList selectedRow]) {
      [mCtrlConfigList selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedIndex] byExtendingSelection:NO];
   }
}

- (void)updateEditZone {
   EndPointConfig *selected = [mCfgMgr getSelectedConfig];
   if (selected) {
      [mCtrlEditCfgAPIKey setStringValue:[selected getApiKey]];
      [mCtrlEditCfgURL setStringValue:[selected getUrl]];
   } else {
      [mCtrlEditCfgAPIKey setStringValue:@""];
      [mCtrlEditCfgURL setStringValue:@""];
   }
   
}

- (void)onCtrlCfgLoadClick {
   if (![self isLoaded]) {
      return;
   }
   NSURL *pCfgUrl = [NSURL URLWithString:[mCtrlCfgURL stringValue]];
   EndPointConfigManager *pCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
   NSString *status = nil;
   if ([pCfgMgr loadJsonConfig:pCfgUrl]) {
      status = NSLocalizedString(@"Success", nil);
   } else {
      status = NSLocalizedString(@"Failure", nil);
   }
   [mCtrlStatus setStringValue:status];
   [self updateUI];
}

- (void)onCtrlCfgDeleteClick {
   if (![self isLoaded]) {
      return;
   }
   NSInteger selectedIndex = [mCtrlConfigList selectedRow];
   if ([mCfgMgr deleteConfigByIndex:selectedIndex]) {
      [self updateUI];
   }
}

- (void)onCtrlCfgSave {
   if (![self isLoaded]) {
      return;
   }
   if ([mCfgMgr saveJsonConfig:[NSURL URLWithString:[mCtrlCfgURL stringValue]]]) {
      [self updateUI];
   }
}

- (void)onCtrlCfgAddClick {
   if (![self isLoaded]) {
      return;
   }
   EndPointConfig *cfg = [[EndPointConfig alloc] initWithAutoId];
   [cfg setApiKey:[mCtrlEditCfgAPIKey stringValue]];
   [cfg setUrl:[mCtrlEditCfgURL stringValue]];
   if ([mCfgMgr addOrUpdateConfig:cfg]) {
      [self updateUI];
   }
}

- (void)onCtrlCfgEditClick {
   if (![self isLoaded]) {
      return;
   }
   EndPointConfig *cfg = [mCfgMgr getSelectedConfig];
   if (!cfg) {
      return;
   }
   [cfg setApiKey:[mCtrlEditCfgAPIKey stringValue]];
   [cfg setUrl:[mCtrlEditCfgURL stringValue]];
   if ([mCfgMgr addOrUpdateConfig:cfg]) {
      [self updateUI];
   }
}

- (void)onLoad {
   [super onLoad];
   NSView *root = [self view];
   
   mCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
   mCtrlBack = [AppUtil setActionHandler:root identifier:@"ctrlBack" target:self action:@selector(onCtrlBackClick)];
   mCtrlCfgSelect = [AppUtil setActionHandler:root identifier:@"ctrlCfgSelect" target:self action:@selector(onCtrlCfgSelectClick)];
   mCtrlCfgDelete = [AppUtil setActionHandler:root identifier:@"ctrlCfgDelete" target:self action:@selector(onCtrlCfgDeleteClick)];
   mCtrlCfgSave = [AppUtil setActionHandler:root identifier:@"ctrlCfgSave" target:self action:@selector(onCtrlCfgSave)];
   mCtrlCfgAdd = [AppUtil setActionHandler:root identifier:@"ctrlCfgAdd" target:self action:@selector(onCtrlCfgAddClick)];
   mCtrlCfgEdit = [AppUtil setActionHandler:root identifier:@"ctrlCfgEdit" target:self action:@selector(onCtrlCfgEditClick)];
   mCtrlEditCfgURL = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlEditCfgURL"];
   mCtrlEditCfgAPIKey = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlEditCfgAPIKey"];
   mCtrlCfgURL = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlCfgURL"];
   
   [mCtrlCfgURL setStringValue:[[mCfgMgr getCurrentCfgURL] absoluteString]];
   
   mCtrlCfgLoad = [AppUtil setActionHandler:root identifier:@"ctrlCfgLoad" target:self action:@selector(onCtrlCfgLoadClick)];
   mCtrlConfigList = (NSTableView *)[AppUtil findViewById:root identifier:@"ctrlConfigList"];
   mCtrlConfigList.dataSource = self;
   [mCtrlConfigList setDelegate:self];
   mCtrlStatus = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlStatus"];
   
   [self updateUI];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
   if ([mCfgMgr selectConfigByIndex:[mCtrlConfigList selectedRow]]) {
      [self updateEditZone];
   }
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
