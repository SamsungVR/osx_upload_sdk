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

#import <SDKLib/User.h>
#import <SDKLib/UserLiveEvent.h>

#import "CtFormListLiveEvents.h"
#import "AppUtil.h"
#import "DgApp.h"


@interface CallbackQueryLiveEvents : NSObject<User_Result_QueryLiveEvents>

- (id)initWith:(CtFormListLiveEvents *)form;

@end

@implementation CtFormListLiveEvents {
   NSButton *mCtrlRefreshAll;
   NSComboBox *mCtrlLiveEventIds;
   NSArray *mQueriedLiveEvents;
   NSMutableArray *mLiveEventDetails;
   NSTableView *mCtrlLiveEventDetails;
   
   id<User> mUser;
   CallbackQueryLiveEvents *mCallbackQueryLiveEvents;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {

   if (row >= 0 && row < [mLiveEventDetails count]) {
      return [mLiveEventDetails objectAtIndex:row];
   }
   return nil;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
   return [mLiveEventDetails count];
}

- (void)onCtrlRefreshAllClick {
   [mUser queryLiveEvents:mCallbackQueryLiveEvents handler:nil closure:nil];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
   if (!mQueriedLiveEvents) {
      return;
   }
   NSInteger selected = [mCtrlLiveEventIds indexOfSelectedItem];
   if (selected >= 0 && selected < [mQueriedLiveEvents count]) {
      id<UserLiveEvent> liveEvent = [mQueriedLiveEvents objectAtIndex:selected];
      [mLiveEventDetails removeAllObjects];
      
   }
}

- (void)onLoad {
   [super onLoad];
   
   mUser = [[DgApp getDgInstance] getUser];
   mCallbackQueryLiveEvents = [[CallbackQueryLiveEvents alloc] initWith:self];
   mLiveEventDetails = [[NSMutableArray alloc] init];
   NSView *root = [self view];
   mCtrlRefreshAll = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlRefreshAll" target:self action:@selector(onCtrlRefreshAllClick)];
   mCtrlLiveEventIds = (NSComboBox *)[AppUtil findViewById:root identifier:@"ctrlLiveEventIds"];
   mCtrlLiveEventDetails = (NSTableView *)[AppUtil findViewById:root identifier:@"ctrlLiveEventDetails"];
   [mCtrlLiveEventIds setDelegate:self];
}

- (void)onQueryLiveEvents:(NSArray *)liveEvents {
   mQueriedLiveEvents = liveEvents;
   [mCtrlLiveEventIds removeAllItems];
   for (id<UserLiveEvent> liveEvent in mQueriedLiveEvents) {
      [mCtrlLiveEventIds addItemWithObjectValue:[liveEvent getId]];
   }
   if ([mQueriedLiveEvents count] > 0) {
      [mCtrlLiveEventIds selectItemAtIndex:0];
   }
}

@end

@implementation CallbackQueryLiveEvents {
   CtFormListLiveEvents *mForm;
}

- (id)initWith:(CtFormListLiveEvents *)form {
   mForm = form;
   return [super init];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   [mForm setLocalizedStatusMsg:@"Failure"];
}

- (void)onSuccess:(Object)closure result:(id)result {
   [mForm onQueryLiveEvents:result];
}

- (void)onException: (Object)closure  exception:(Exception)exception {
}

- (void)onCancelled:(Object)closure {
}

@end
