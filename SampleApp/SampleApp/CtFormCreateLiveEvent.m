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

#import "SDKLib/User.h"

#import "CtFormCreateLiveEvent.h"
#import "AppUtil.h"
#import "DgApp.h"

@interface CallbackCreateLiveEvent : NSObject<User_Result_CreateLiveEvent>

- (id)initWith:(CtFormCreateLiveEvent *)form;

@end

@implementation CtFormCreateLiveEvent {
   NSButton *mCtrlCreate, *mCtrlCopyRtmlUrlToClipboard;
   NSTextField *mCtrlStatusMsg, *mCtrlTitle, *mCtrlDescription, *mCtrlRtmpUrl;
   NSComboBox *mCtrlPermission, *mCtrlSource, *mCtrlVideoStereoscopyType;
   
   CallbackCreateLiveEvent *mCallbackCreateLiveEvent;
   
   id<User> mUser;
}

- (void)onCtrlCreateClick {
   [mUser createLiveEvent:[mCtrlTitle stringValue] description:[mCtrlDescription stringValue]
               permission:(UserVideo_Permission)[mCtrlPermission indexOfSelectedItem]
               source:(UserLiveEvent_Source)[mCtrlSource indexOfSelectedItem]
               videoStereoscopyType:(UserVideo_VideoStereoscopyType)[mCtrlVideoStereoscopyType indexOfSelectedItem]
               callback:mCallbackCreateLiveEvent handler:nil closure:nil];
}

- (void)onCreateLiveEvent:(id<UserLiveEvent>) userLiveEvent {
   NSString *tmpl = NSLocalizedString(@"CreatedLiveEvent", nil);
   NSString *msg = [NSString stringWithFormat:tmpl, [userLiveEvent getId]];
   [self setStatusMsg:msg];
   [mCtrlRtmpUrl setStringValue:[[userLiveEvent getProducerUrl] absoluteString]];
}

- (NSTextField *)getStatusMsgCtrl {
   return mCtrlStatusMsg;
}

- (void)onCtrlCopyRtmpUrlToClipboardClick {
   [[NSPasteboard generalPasteboard] clearContents];
   [[NSPasteboard generalPasteboard] setString:[mCtrlRtmpUrl stringValue]  forType:NSStringPboardType];
}

- (void)onLoad {
   [super onLoad];
   mUser = [[DgApp getDgInstance] getUser];
   mCallbackCreateLiveEvent = [[CallbackCreateLiveEvent alloc] initWith:self];
   
   NSView *root = [self view];
   mCtrlCreate = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlCreate" target:self action:@selector(onCtrlCreateClick)];
   mCtrlStatusMsg = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlStatusMsg"];
   mCtrlTitle = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlTitle"];
   mCtrlDescription = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlDescription"];
   mCtrlSource = (NSComboBox *)[AppUtil findViewById:root identifier:@"ctrlSource"];
   mCtrlPermission = (NSComboBox *)[AppUtil findViewById:root identifier:@"ctrlPermission"];
   mCtrlVideoStereoscopyType = (NSComboBox *)[AppUtil findViewById:root identifier:@"ctrlVideoStereoscopyType"];
   mCtrlRtmpUrl = (NSTextField *)[AppUtil findViewById:root identifier:@"ctrlRtmpUrl"];
   mCtrlCopyRtmlUrlToClipboard = (NSButton *)[AppUtil setActionHandler:root identifier:@"ctrlCopyRtmpUrlToClipboard"
                                                                target:self action:@selector(onCtrlCopyRtmpUrlToClipboardClick)];
}

@end



@implementation CallbackCreateLiveEvent {
   CtFormCreateLiveEvent *mForm;
}

- (id)initWith:(CtFormCreateLiveEvent *)form {
   mForm = form;
   return [super init];
}

- (void)onFailure:(Object)closure status:(NSInteger)status {
   [mForm setLocalizedStatusMsg:@"Failure"];
}

- (void)onSuccess:(Object)closure result:(id)result {
   [mForm onCreateLiveEvent:result];
}

- (void)onException: (Object)closure  exception:(Exception)exception {
}

- (void)onCancelled:(Object)closure {
}

@end
