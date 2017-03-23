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
    UIControl *mCtrlBack, *mCtrlSave, *mCtrlDelete, *mCtrlAdd, *mCtrlUpdate;
    UITextField *mCtrlEditURL, *mCtrlEditAPIKey, *mCtrlStatus;
    UITableView *mCtrlConfigList;
    EndPointConfigManager *mCfgMgr;
}

- (void)onCtrlBackClick {
    if (![self isLoaded]) {
        return;
    }
    [[DgApp getDgInstance] showForm:[CtFormLogin alloc] nibName:@"FormLogin"];
}


- (void)updateUI {
    [mCtrlConfigList reloadData];
    [self updateEditZone];
    NSInteger selectedIndex = [mCfgMgr getSelectedIndex];
    if (-1 != selectedIndex) {
        NSUInteger indexes[2] = {0, selectedIndex};
        NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
        [mCtrlConfigList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)updateEditZone {
    EndPointConfig *selected = [mCfgMgr getSelectedConfig];
    if (selected) {
        [mCtrlEditAPIKey setText:[selected getApiKey]];
        [mCtrlEditURL setText:[selected getUrl]];
    } else {
        [mCtrlEditAPIKey setText:@""];
        [mCtrlEditURL setText:@""];
    }

}

- (void)onCtrlCfgLoadClick {
    if (![self isLoaded]) {
        return;
    }
    EndPointConfigManager *pCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
    NSString *status = nil;
    if ([pCfgMgr loadJsonConfig]) {
        status = NSLocalizedString(@"Success", nil);
    } else {
        status = NSLocalizedString(@"Failure", nil);
    }
    [mCtrlStatus setText:status];
    [self updateUI];
}

- (void)onCtrlCfgDeleteClick {
    if (![self isLoaded]) {
        return;
    }
    NSInteger selectedIndex = [[mCtrlConfigList indexPathForSelectedRow] indexAtPosition:0];
    if ([mCfgMgr deleteConfigByIndex:selectedIndex]) {
        [self updateUI];
    }
}

- (void)onCtrlCfgSave {
    if (![self isLoaded]) {
        return;
    }
    if ([mCfgMgr saveJsonConfig]) {
        [self updateUI];
    }
}

- (void)onCtrlCfgAddClick {
    if (![self isLoaded]) {
        return;
    }
    EndPointConfig *cfg = [[EndPointConfig alloc] initWithAutoId];
    [cfg setApiKey:[mCtrlEditAPIKey text]];
    [cfg setUrl:[mCtrlEditURL text]];
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
    [cfg setApiKey:[mCtrlEditAPIKey text]];
    [cfg setUrl:[mCtrlEditURL text]];
    if ([mCfgMgr addOrUpdateConfig:cfg]) {
        [self updateUI];
    }
}

- (void)onLoad {
    [super onLoad];
    UIView *root = [self view];

    mCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
    mCtrlBack = [AppUtil setActionHandler:root identifier:@"ctrlBack" target:self action:@selector(onCtrlBackClick)];
    mCtrlDelete = [AppUtil setActionHandler:root identifier:@"ctrlDelete" target:self action:@selector(onCtrlCfgDeleteClick)];
    mCtrlSave = [AppUtil setActionHandler:root identifier:@"ctrlSave" target:self action:@selector(onCtrlCfgSave)];
    mCtrlAdd = [AppUtil setActionHandler:root identifier:@"ctrlAdd" target:self action:@selector(onCtrlCfgAddClick)];
    mCtrlUpdate = [AppUtil setActionHandler:root identifier:@"ctrlUpdate" target:self action:@selector(onCtrlCfgEditClick)];
    mCtrlEditURL = (UITextField *)[AppUtil findViewById:root identifier:@"ctrlEditURL"];
    mCtrlEditAPIKey = (UITextField *)[AppUtil findViewById:root identifier:@"ctrlEditAPIKey"];

    mCtrlConfigList = (UITableView *)[AppUtil findViewById:root identifier:@"ctrlConfigList"];
    mCtrlConfigList.dataSource = self;
    [mCtrlConfigList setDelegate:self];
    mCtrlStatus = (UITextField *)[AppUtil findViewById:root identifier:@"ctrlStatus"];

    [self updateUI];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([mCfgMgr selectConfigByIndex:[[mCtrlConfigList indexPathForSelectedRow] indexAtPosition:0]]) {
        [self updateEditZone];
    }
}

- (id)init {
    mCfgMgr = [[DgApp getDgInstance] getEndPointCfgMgr];
    return [super init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mCfgMgr getCount];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    //[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSInteger row = [indexPath row];

    NSArray *items = [mCfgMgr getList];
    if (items && row >= 0 && row < [items count]) {
        EndPointConfig *cfg = [items objectAtIndex:row];
        cell.textLabel.text = [cfg getUrl];
    }
    return cell;
}


@end
