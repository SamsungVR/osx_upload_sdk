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

#define MAX_PERMISSIONS 5

static NSString * Permissions[MAX_PERMISSIONS];

@interface CallbackQueryLiveEvents : NSObject<User_Result_QueryLiveEvents>

- (id)initWith:(CtFormListLiveEvents *)form;

@end


@interface CallbackDeleteLiveEvent : NSObject<UserLiveEvent_Result_Delete>

- (id)initWith:(CtFormListLiveEvents *)form;

@end

@implementation CtFormListLiveEvents {
   NSButton *mCtrlRefreshAll, *mCtrlDelete, *mCtrlCopyRtmpUrl;
   NSComboBox *mCtrlLiveEventIds;
   NSArray *mQueriedLiveEvents;
   NSMutableArray *mLiveEventDetails;
   NSTableView *mCtrlLiveEventDetails;
   
   id<User> mUser;
   CallbackQueryLiveEvents *mCallbackQueryLiveEvents;
   CallbackDeleteLiveEvent *mCallbackDeleteLiveEvent;
}

- (NSString *)permissionToStr:(UserVideo_Permission)permission {
   switch (permission) {
      case UserVideo_Permission_PUBLIC:
         return NSLocalizedString(@"UserVideo_Permission_PUBLIC", nil);
      case UserVideo_Permission_PRIVATE:
         return NSLocalizedString(@"UserVideo_Permission_PRIVATE", nil);
      case UserVideo_Permission_VR_ONLY:
         return NSLocalizedString(@"UserVideo_Permission_VR_ONLY", nil);
      case UserVideo_Permission_UNLISTED:
         return NSLocalizedString(@"UserVideo_Permission_UNLISTED", nil);
      case UserVideo_Permission_WEB_ONLY:
         return NSLocalizedString(@"UserVideo_Permission_WEB_ONLY", nil);
   }
   return NULL;
}

- (NSString *)stereoscopyTypeToStr:(UserVideo_VideoStereoscopyType)steroescopyType {
   switch (steroescopyType) {
      case UserVideo_VideoStereoscopyType_DEFAULT:
         return NSLocalizedString(@"UserVideo_VideoStereoscopyType_DEFAULT", nil);
      case UserVideo_VideoStereoscopyType_MONOSCOPIC:
         return NSLocalizedString(@"UserVideo_VideoStereoscopyType_MONOSCOPIC", nil);
      case UserVideo_VideoStereoscopyType_DUAL_FISHEYE:
         return NSLocalizedString(@"UserVideo_VideoStereoscopyType_DUAL_FISHEYE", nil);
      case UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC:
         return NSLocalizedString(@"UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC", nil);
      case UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC:
         return NSLocalizedString(@"UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC", nil);
   }
   return NULL;
}

- (NSString *)sourceToStr:(UserLiveEvent_Source)source {
   switch (source) {
      case UserLiveEvent_Source_RTMP:
         return NSLocalizedString(@"UserLiveEvent_Source_RTMP", nil);
      case UserLiveEvent_Source_SEGMENTED_TS:
         return NSLocalizedString(@"UserLiveEvent_Source_SEGMENTED_TS", nil);
      case UserLiveEvent_Source_SEGMENTED_MP4:
         return NSLocalizedString(@"UserLiveEvent_Source_SEGMENTED_MP4", nil);
   }
   return NULL;
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

- (void)addIfValidToLiveEventDetails:(NSString *)data {
   if (data) {
      [mLiveEventDetails addObject:data];
   }
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
   if (!mQueriedLiveEvents) {
      return;
   }
   NSInteger selected = [mCtrlLiveEventIds indexOfSelectedItem];
   if (selected >= 0 && selected < [mQueriedLiveEvents count]) {
      id<UserLiveEvent> liveEvent = [mQueriedLiveEvents objectAtIndex:selected];
      [mLiveEventDetails removeAllObjects];
      [self addIfValidToLiveEventDetails:[liveEvent getTitle]];
      [self addIfValidToLiveEventDetails:[liveEvent getDescription]];
      [self addIfValidToLiveEventDetails:[[liveEvent getViewUrl] absoluteString]];
      [self addIfValidToLiveEventDetails:[[liveEvent getProducerUrl] absoluteString]];
      NSString *permission = [self permissionToStr:[liveEvent getPermission]];
      [self addIfValidToLiveEventDetails:permission];
      NSString *stereoscopyType = [self stereoscopyTypeToStr:[liveEvent getVideoStereoscopyType]];
      [self addIfValidToLiveEventDetails:stereoscopyType];
      NSString *source = [self sourceToStr:[liveEvent getSource]];
      [self addIfValidToLiveEventDetails:source];
      [mCtrlLiveEventDetails reloadData];
   }
}

- (id<UserLiveEvent>)getSelectedLiveEvent {
   if (!mQueriedLiveEvents) {
      return nil;
   }
   NSInteger selectedIndex = [mCtrlLiveEventIds indexOfSelectedItem];
   if (selectedIndex < 0 || selectedIndex >= [mQueriedLiveEvents count]) {
      return nil;
   }
   return [mQueriedLiveEvents objectAtIndex:selectedIndex];
}

- (void)onCtrlDelete {
   id<UserLiveEvent> selectedLiveEvent = [self getSelectedLiveEvent];
   if (selectedLiveEvent) {
      [selectedLiveEvent del:mCallbackDeleteLiveEvent handler:nil closure:nil];
   }
}

- (void)onCtrlCopyRtmpUrl {
   id<UserLiveEvent> selectedLiveEvent = [self getSelectedLiveEvent];
   [[NSPasteboard generalPasteboard] clearContents];
   if (selectedLiveEvent) {
      NSURL *producerUrl = [selectedLiveEvent getProducerUrl];
      if (producerUrl) {
         [[NSPasteboard generalPasteboard] setString:[producerUrl absoluteString]  forType:NSStringPboardType];
      }
   }
}

- (void)onLoad {
   [super onLoad];
   
   mUser = [[DgApp getDgInstance] getUser];
   mCallbackQueryLiveEvents = [[CallbackQueryLiveEvents alloc] initWith:self];
   mCallbackDeleteLiveEvent = [[CallbackDeleteLiveEvent alloc] initWith:self];
   
   mLiveEventDetails = [[NSMutableArray alloc] init];
   NSView *root = [self view];
   mCtrlRefreshAll = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlRefreshAll" target:self action:@selector(onCtrlRefreshAllClick)];
   mCtrlDelete = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlDelete" target:self action:@selector(onCtrlDelete)];
   mCtrlCopyRtmpUrl = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlCopyRtmpUrl" target:self action:@selector(onCtrlCopyRtmpUrl)];
   mCtrlLiveEventIds = (NSComboBox *)[AppUtil findViewById:root identifier:@"ctrlLiveEventIds"];
   mCtrlLiveEventDetails = (NSTableView *)[AppUtil findViewById:root identifier:@"ctrlLiveEventDetails"];

   [mCtrlLiveEventIds setDelegate:self];
   mCtrlLiveEventDetails.dataSource = self;
   
   [self onCtrlRefreshAllClick];
}

- (void)onQueryLiveEvents:(NSArray *)liveEvents {
   mQueriedLiveEvents = liveEvents;
   [mCtrlLiveEventIds removeAllItems];
   [mCtrlLiveEventIds setStringValue:@""];
   [mLiveEventDetails removeAllObjects];
   [mCtrlLiveEventDetails reloadData];
   
   for (id<UserLiveEvent> liveEvent in mQueriedLiveEvents) {
      [mCtrlLiveEventIds addItemWithObjectValue:[liveEvent getId]];
   }
   if ([mQueriedLiveEvents count] > 0) {
      [mCtrlLiveEventIds selectItemAtIndex:0];
   }
}

- (void)onDeleteLiveEvent {
   [self onCtrlRefreshAllClick];
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

@implementation CallbackDeleteLiveEvent {
   CtFormListLiveEvents *mForm;
}

- (id)initWith:(CtFormListLiveEvents *)form {
   mForm = form;
   return [super init];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   [mForm setLocalizedStatusMsg:@"Failure"];
}

- (void)onSuccess:(Object)closure {
   [mForm onDeleteLiveEvent];
}

- (void)onException: (Object)closure  exception:(Exception)exception {
}

- (void)onCancelled:(Object)closure {
}

@end
