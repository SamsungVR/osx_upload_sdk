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

#import "Util.h"
#import "User_Impl.h"
#import "ObjectHolder.h"
#import "ClientWorkItem.h"
#import "UserLiveEvent_Impl.h"
#import "UserVideo_Impl.h"

static const NSString
* const PROP_NAME = @"name",
* const PROP_PROFILE_PIC = @"profile_pic",
* const PROP_EMAIL = @"email",
* const PROP_SESSION_TOKEN = @"session_token",
* const PROP_USER_ID = @"user_id";

@interface WorkItemTypeCreateLiveEvent : NSObject<AsyncWorkItemType>
@end

@interface WorkItemCreateLiveEvent : ClientWorkItem

- (id)initWithClient:(APIClient_Impl *)apiClient;
- (void)set:(User_Impl *)user title:(NSString *)title description:(NSString *)description permission:(UserVideo_Permission)permission
     source:(UserLiveEvent_Source)source videoStereoscopyType:(UserVideo_VideoStereoscopyType)videoStereoscopyType
   callback:(id<User_Result_CreateLiveEvent>)callback handler:(Handler)handler closure:(Object)closure;

@end

@implementation WorkItemTypeCreateLiveEvent

- (AsyncWorkItem *)newInstance:(APIClient_Impl *)apiClient {
   return [[WorkItemCreateLiveEvent alloc] initWithClient:apiClient];
}

@end

static id<AsyncWorkItemType> sTypeCreateLiveEvent = nil;

@implementation WorkItemCreateLiveEvent {
   User_Impl *mUser;
   NSString *mTitle, *mDescription;
   UserVideo_Permission mPermission;
   UserVideo_VideoStereoscopyType mVideoStereoscopyType;
   UserLiveEvent_Source mSource;
}

- (id)initWithClient:(APIClient_Impl *)apiClient {
   return [super initWith:apiClient type:sTypeCreateLiveEvent];
}

- (void)set:(User_Impl *)user title:(NSString *)title description:(NSString *)description permission:(UserVideo_Permission)permission
     source:(UserLiveEvent_Source)source videoStereoscopyType:(UserVideo_VideoStereoscopyType)videoStereoscopyType
   callback:(id<User_Result_CreateLiveEvent>)callback handler:(Handler)handler closure:(Object)closure {
   
   [super set:callback handler:handler closure:closure];
   mUser = user;
   mTitle = title;
   mDescription = description;
   mPermission = permission;
   mSource = source;
   mVideoStereoscopyType = videoStereoscopyType;
   
}

- (void)onRun {
   id<HttpPlugin_PostRequest> request = nil;
   
   NSMutableDictionary *jsonParam = [[NSMutableDictionary alloc] init];
   jsonParam[@"title"] = mTitle;
   jsonParam[@"description"] = mDescription;
   NSString *temp1 = [User_Impl userVideoPermissionToStr:mPermission];
   if (temp1) {
      jsonParam[@"permission"] = temp1;
   }
   NSString *temp2 = [User_Impl userVideoStereoscopyTypeToStr:mVideoStereoscopyType];
   if (temp2) {
      jsonParam[@"stereoscopic_type"] = temp2;
   }
   NSString *temp3 = [User_Impl userLiveEventSourceToStr:mSource];
   if (temp3) {
      jsonParam[@"source"] = temp3;
   }
   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonParam options:0 error:nil];
   //NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
   Headers headers = {
      HEADER_CONTENT_LENGTH, [NSString stringWithFormat:@"%lu", [jsonData length]],
      HEADER_CONTENT_TYPE, [NSString stringWithFormat:@"application/json%@", CONTENT_TYPE_CHARSET_SUFFIX_UTF8],
      HEADER_API_KEY, [[self getApiClient] getApiKey],
      HEADER_SESSION_TOKEN, [mUser getSessionToken],
      NULL
   };
   NSString *userId = [mUser getUserId];
   request = [self newPostRequest:[NSString stringWithFormat:@"user/%@/video", userId] headers:headers];
   if (!request) {
      [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_NULL_CONNECTION];
      return;
   }
   [self writeBytes:request data:jsonData debugMsg:nil];
   NSInteger responseCode = [self getResponseCode:request];
   NSData *response = [self readHttpStream:request debugMsg:nil];
   if (!response) {
      [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_STREAM_READ_FAILURE];
      return;
   }
   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
   if ([self isHttpSuccess:responseCode]) {
      
      NSString *videoId = [Util jsonOptObj:jsonResponse key:@"video_id" def:NULL];
      NSString *ingestUrl = [Util jsonOptObj:jsonResponse key:@"ingest_url" def:NULL];
      NSString *viewUrl = [Util jsonOptObj:jsonResponse key:@"view_url" def:NULL];
      
      if (videoId) {
         UserLiveEvent_Impl *eventObj = [[UserLiveEvent_Impl alloc] initWithParams:mUser
                                                                           videoId:videoId title:mTitle description:mDescription permission:mPermission
                                                                            source:mSource videoSteroscopyType:mVideoStereoscopyType ingestUrl:ingestUrl viewUrl:viewUrl];
         [self dispatchSuccessWithResult:eventObj];
         return;
      }
   }
   
   NSInteger status = [Util jsonOptInt:jsonResponse key:@"status" def:VR_RESULT_STATUS_SERVER_RESPONSE_NO_STATUS_CODE];
   [self dispatchFailure:status];
}

@end

@interface WorkItemTypeQueryLiveEvents : NSObject<AsyncWorkItemType>
@end

@interface WorkItemQueryLiveEvents : ClientWorkItem

- (id)initWithClient:(APIClient_Impl *)apiClient;
- (void)set:(User_Impl *)user callback:(id<User_Result_QueryLiveEvents>)callback handler:(Handler)handler closure:(Object)closure;

@end


@implementation WorkItemTypeQueryLiveEvents

- (AsyncWorkItem *)newInstance:(APIClient_Impl *)apiClient {
   return [[WorkItemQueryLiveEvents alloc] initWithClient:apiClient];
}

@end

static id<AsyncWorkItemType> sTypeQueryLiveEvents = nil;

@implementation WorkItemQueryLiveEvents {
   User_Impl *mUser;
}


- (id)initWithClient:(APIClient_Impl *)apiClient {
   return [super initWith:apiClient type:sTypeQueryLiveEvents];
}

- (void)set:(User_Impl *)user
   callback:(id<User_Result_QueryLiveEvents>)callback handler:(Handler)handler closure:(Object)closure {
   
   [super set:callback handler:handler closure:closure];
   mUser = user;
}

- (void)onRun {
   id<HttpPlugin_GetRequest> request = nil;
   
   Headers headers = {
      HEADER_API_KEY, [[self getApiClient] getApiKey],
      HEADER_SESSION_TOKEN, [mUser getSessionToken],
      NULL
   };
   NSString *userId = [mUser getUserId];
   request = [self newGetRequest:[NSString stringWithFormat:@"user/%@/video?source=live", userId] headers:headers];
   if (!request) {
      [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_NULL_CONNECTION];
      return;
   }
   NSInteger responseCode = [self getResponseCode:request];
   NSData *response = [self readHttpStream:request debugMsg:nil];
   if (!response) {
      [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_STREAM_READ_FAILURE];
      return;
   }
   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
   if ([self isHttpSuccess:responseCode]) {
      NSMutableArray *liveEvents = [[NSMutableArray alloc] init];
      NSArray *items = [Util jsonOptObj:jsonResponse key:@"videos" def:NULL];
      if (items) {
         for (NSDictionary *dict in items) {
            [liveEvents addObject:[[UserLiveEvent_Impl alloc] initWith:mUser jsonObject:dict]];
         }
         [self dispatchSuccessWithResult:liveEvents];
         return;
      }
   }
   
   NSInteger status = [Util jsonOptInt:jsonResponse key:@"status" def:VR_RESULT_STATUS_SERVER_RESPONSE_NO_STATUS_CODE];
   [self dispatchFailure:status];
}

@end

@interface WorkItemVideoUploadBase : ClientWorkItem
@end

@implementation WorkItemVideoUploadBase {
   ObjectHolder *mCancelHolder;
}

- (id)initWith:(APIClient_Impl *)apiClient type:(id<AsyncWorkItemType>)type {
   return [super initWith:apiClient type:type];
}

- (void)set:(ObjectHolder *) cancelHolder callback:(id<User_Result_UploadVideo>)callback handler:(Handler)handler
    closure:(Object)closure {
   [super set:callback handler:handler closure:closure];
   mCancelHolder = cancelHolder;
}

- (ObjectHolder *)getCancelHolder {
   return mCancelHolder;
}


- (void)cancel {
   @synchronized (self) {
      [super cancel];
      if (NULL != mCancelHolder) {
         [mCancelHolder set:[NSNumber numberWithBool:TRUE]];
      }
   }
}

- (BOOL)isCancelled {
   @synchronized (self) {
      if (NULL != mCancelHolder) {
         NSNumber *val = [mCancelHolder get];
         if (NULL != val) {
            if (TRUE == [val boolValue]) {
               return TRUE;
            }
         }
      }
      return [super isCancelled];
   }
}

@end

@interface VideoIdAvailableCallbackNotifier : Util_CallbackNotifier

- (id)initWithOtherAndVideo:(id<ResultCallbackHolder>)other video:(id<UserVideo>)video;

@end

@implementation VideoIdAvailableCallbackNotifier {
   id<UserVideo> mUserVideo;
}

- (id)initWithOtherAndVideo:(id<ResultCallbackHolder>)other video:(id<UserVideo>)userVideo {
   mUserVideo = userVideo;
   return [super initWithOther:other];
}

- (void)notify:(id)callback closure:(Object)closure {
   id<User_Result_UploadVideo> tCallback = (id<User_Result_UploadVideo>)callback;
   [tCallback onVideoIdAvailable:closure video:mUserVideo];
}

@end

@interface WorkItemTypeNewVideoUpload : NSObject<AsyncWorkItemType>
@end

@interface WorkItemNewVideoUpload : WorkItemVideoUploadBase

- (id)initWithClient:(APIClient_Impl *)apiClient;

@end

@implementation WorkItemTypeNewVideoUpload

- (AsyncWorkItem *)newInstance:(APIClient_Impl *)apiClient {
   return [[WorkItemNewVideoUpload alloc] initWithClient:apiClient];
}

@end

static id<AsyncWorkItemType> sTypeNewVideoUpload = nil;

@implementation WorkItemNewVideoUpload {
   User_Impl *mUser;
   UserVideo_Permission mPermission;
   
   NSInputStream *mSource;
   long mLength;
   NSString *mTitle, *mDescription;
}

- (id)initWithClient:(APIClient_Impl *)apiClient {
   return [super initWith:apiClient type:sTypeNewVideoUpload];
}

- (void)set:(User_Impl *)user source:(NSInputStream *)source length:(long)length title:(NSString *)title
description:(NSString *)description permission:(UserVideo_Permission)permission
   callback:(id<User_Result_UploadVideo>)callback handler:(Handler)handler closure:(Object)closure {
   [super set:[[ObjectHolder alloc] initWith:[NSNumber numberWithBool:FALSE]] callback:callback handler:handler closure:closure];
   mUser = user;
   mTitle = title;
   mDescription = description;
   mSource = source;
   mLength = length;
   mPermission = permission;
   
}

- (void)onRun {
   
   Headers headers0 = {
      HEADER_API_KEY, [[self getApiClient] getApiKey],
      HEADER_SESSION_TOKEN, [mUser getSessionToken],
      NULL
   };
   Headers headers1 = {
      HEADER_CONTENT_LENGTH, @"0",
      HEADER_CONTENT_TYPE, [NSString stringWithFormat:@"application/json%@", CONTENT_TYPE_CHARSET_SUFFIX_UTF8],
      headers0[0], headers0[1], headers0[2], headers0[3],
      NULL
   };
   
   NSMutableDictionary *jsonParam = [[NSMutableDictionary alloc] init];
   jsonParam[@"title"] = mTitle;
   jsonParam[@"description"] = mDescription;
   jsonParam[@"length"] = [NSNumber numberWithInteger:mLength];
   NSString *temp1 = [User_Impl userVideoPermissionToStr:mPermission];
   if (temp1) {
      jsonParam[@"permission"] = temp1;
   }
   
   NSString *videoId = nil;
   NSString *uploadId = nil;
   NSString *signedUrl = nil;
   NSNumber *chunkSize = nil;
   NSNumber *numChunks = nil;
   
   NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonParam options:0 error:nil];
   
   headers1[1] = [NSString stringWithFormat:@"%lu", [jsonData length]];
   NSString *userId = [mUser getUserId];
   id<HttpPlugin_PostRequest> request = [self newPostRequest:[NSString stringWithFormat:@"user/%@/video", userId] headers:headers1];
   if (!request) {
      [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_NULL_CONNECTION];
      return;
   }
   [self writeBytes:request data:jsonData debugMsg:nil];
   if ([self isCancelled]) {
      [self dispatchCancelled];
      return;
   }
   NSInteger responseCode = [self getResponseCode:request];
   NSData *data4 = [self readHttpStream:request debugMsg:nil];
   
   if (!data4) {
      [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_STREAM_READ_FAILURE];
      return;
   }
   NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data4 options:0 error:nil];
   if (![self isHttpSuccess:responseCode]) {
      NSInteger status = [Util jsonOptInt:jsonObject key:@"status" def:VR_RESULT_STATUS_SERVER_RESPONSE_NO_STATUS_CODE];
      [self dispatchFailure:status];
      return;
   }
   if ([self isCancelled]) {
      [self dispatchCancelled];
      return;
   }
   
   videoId = [Util jsonOptObj:jsonObject key:@"video_id" def:NULL];
   uploadId = [Util jsonOptObj:jsonObject key:@"upload_id" def:NULL];
   signedUrl = [Util jsonOptObj:jsonObject key:@"signed_url" def:NULL];
   
   chunkSize = [Util jsonOptObj:jsonObject key:@"chunk_size" def:NULL];
   numChunks = [Util jsonOptObj:jsonObject key:@"chunks" def:NULL];
   
   UserVideo_Impl *userVideo = nil; //new UserVideo_Impl(mUser, mTitle, mDescription, mPermission);
   VideoIdAvailableCallbackNotifier *notifier = [[VideoIdAvailableCallbackNotifier alloc] initWithOtherAndVideo:[self getCallbackHolder] video:userVideo];
   
   if (![userVideo uploadContent:[self getCancelHolder] source:mSource length:mLength initialSignedUrl:signedUrl videoId:videoId uploadId:uploadId
                       chunkSize:[chunkSize longValue] numChunks:[numChunks longValue] callbackHolder:[self getCallbackHolder]]) {
      [self dispatchUncounted:notifier];
      [self dispatchFailure:USER_RESULT_STATUS_UPLOADVIDEO_CONTENT_UPLOAD_SCHEDULING_FAILED];
   } else {
      [self dispatchCounted:notifier];
   }
}

@end

@interface UploadVideoCanceller : NSObject<AsyncWorkQueue_IterationObserver>
   
- (id)initWithClosure:(Object)closure;
- (bool)wasFound;
   
@end

@implementation UploadVideoCanceller {
   Object mClosure;
   bool mFound;
}

- (id)initWithClosure:(Object)closure {
   mClosure = closure;
   mFound = FALSE;
   
   return [super init];
}

- (bool)wasFound {
   return mFound;
}

- (bool)onIterate:(AsyncWorkItem *)workItem args:(Object)args {
   id<AsyncWorkItemType> type = [workItem getType];
   
   if (type == sTypeNewVideoUpload) {
      ClientWorkItem *cWorkItem = (ClientWorkItem *)workItem;
      Object uploadClosure = [cWorkItem getClosure];
      if ([Util checkEquals:mClosure b:uploadClosure]) {
         [workItem cancel];
         mFound = true;
      }
   }
   return true;
}

@end

@implementation User_Impl

+ (void)initialize {
   sTypeCreateLiveEvent = [[WorkItemTypeCreateLiveEvent alloc] init];
   sTypeQueryLiveEvents = [[WorkItemTypeQueryLiveEvents alloc] init];
   sTypeNewVideoUpload = [[WorkItemTypeNewVideoUpload alloc] init];
}


- (id)initWith:(APIClient_Impl *)apiClient jsonObject:(NSDictionary *)jsonObject {
   return [super initWithDict:jsonObject container:apiClient];
}

- (NSString *)getName {
   return [super getLocked:PROP_NAME];
}

- (NSURL *)getProfilePicUrl {
   return [NSURL URLWithString:[super getLocked:PROP_PROFILE_PIC]];
}

- (NSString *)getEmail {
   return [super getLocked:PROP_EMAIL];
}

- (NSString *)getSessionToken {
   return [super getLocked:PROP_SESSION_TOKEN];
}

- (NSString *)getUserId {
   return [super getLocked:PROP_USER_ID];
}

- (bool)createLiveEvent:(NSString *)title description:(NSString *)description
             permission:(UserVideo_Permission)permission source:(UserLiveEvent_Source)source
   videoStereoscopyType:(UserVideo_VideoStereoscopyType)videoStereoscopyType
               callback:(id<User_Result_CreateLiveEvent>)callback handler:(Handler)handler closure:(Object)closure {
   AsyncWorkQueue *workQueue = [(APIClient_Impl *)[super getContainer] getAsyncWorkQueue];
   WorkItemCreateLiveEvent *workItem = (WorkItemCreateLiveEvent *)[workQueue obtainWorkItem:sTypeCreateLiveEvent];
   [workItem set:self title:title description:description permission:permission source:source videoStereoscopyType:videoStereoscopyType
        callback:callback handler:handler closure:closure];
   return [workQueue enqueue:workItem];
}

- (bool)uploadVideo:(NSInputStream *)source length:(long)length title:(NSString *)title description:(NSString *)description
         permission:(UserVideo_Permission)permission callback:(id<User_Result_UploadVideo>)callback handler:(Handler)handler closure:(Object)closure {
   AsyncWorkQueue *workQueue = [(APIClient_Impl *)[super getContainer] getAsyncWorkQueue];
   WorkItemNewVideoUpload *workItem = (WorkItemNewVideoUpload *)[workQueue obtainWorkItem:sTypeNewVideoUpload];
   
   [workItem set:self source:source length:length title:title description:description
      permission:permission callback:callback handler:handler closure:closure];
   return [workQueue enqueue:workItem];
}

- (bool)cancelUploadVideo:(Object)closure {
   AsyncWorkQueue *workQueue = [(APIClient_Impl *)[super getContainer] getAsyncWorkQueue];
   
   UploadVideoCanceller *canceller = [[UploadVideoCanceller alloc] initWithClosure:closure];
   [workQueue iterateWorkItems:canceller args:NULL];
   bool ret = [canceller wasFound];
   return ret;
}

- (bool)queryLiveEvents:(id<User_Result_QueryLiveEvents>)callback handler:(Handler)handler closure:(Object)closure {
   AsyncWorkQueue *workQueue = [(APIClient_Impl *)[super getContainer] getAsyncWorkQueue];
   WorkItemQueryLiveEvents *workItem = (WorkItemQueryLiveEvents *)[workQueue obtainWorkItem:sTypeQueryLiveEvents];
   [workItem set:self callback:callback handler:handler closure:closure];
   return [workQueue enqueue:workItem];
}

static NSString const * Str_UserVideo_Permission_UNLISTED = @"Unlisted";
static NSString const * Str_UserVideo_Permission_PUBLIC = @"Public";
static NSString const * Str_UserVideo_Permission_VR_ONLY = @"VR Only";
static NSString const * Str_UserVideo_Permission_WEB_ONLY = @"Web Only";
static NSString const * Str_UserVideo_Permission_PRIVATE = @"Private";

+ (const NSString *)userVideoPermissionToStr:(UserVideo_Permission)permission {
   switch (permission) {
         
      case UserVideo_Permission_UNLISTED:
         return Str_UserVideo_Permission_UNLISTED;
      case UserVideo_Permission_PUBLIC:
         return Str_UserVideo_Permission_PUBLIC;
      case UserVideo_Permission_VR_ONLY:
         return Str_UserVideo_Permission_VR_ONLY;
      case UserVideo_Permission_WEB_ONLY:
         return Str_UserVideo_Permission_WEB_ONLY;
      case UserVideo_Permission_PRIVATE:
         break;
   }
   return Str_UserVideo_Permission_PRIVATE;
}

+ (UserVideo_Permission)userVideoPermissionFromStr:(NSString *)permission {
   if ([Str_UserVideo_Permission_UNLISTED isEqualToString:permission]) {
      return UserVideo_Permission_UNLISTED;
   }
   if ([Str_UserVideo_Permission_PUBLIC isEqualToString:permission]) {
      return UserVideo_Permission_PUBLIC;
   }
   if ([Str_UserVideo_Permission_VR_ONLY isEqualToString:permission]) {
      return UserVideo_Permission_VR_ONLY;
   }
   if ([Str_UserVideo_Permission_WEB_ONLY isEqualToString:permission]) {
      return UserVideo_Permission_WEB_ONLY;
   }
   return UserVideo_Permission_PRIVATE;
   
}

static NSString const * Str_UserVideo_VideoStereoscopyType_MONOSCOPIC = @"monoscopic";
static NSString const * Str_UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC = @"left-right";
static NSString const * Str_UserVideo_VideoStereoscopyType_DUAL_FISHEYE = @"dual-fisheye";
static NSString const * Str_UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC = @"top-bottom";
static NSString const * Str_UserVideo_VideoStereoscopyType_DEFAULT = NULL;

+ (NSString const *)userVideoStereoscopyTypeToStr:(UserVideo_VideoStereoscopyType)videoStereoscopyType {
   switch (videoStereoscopyType) {
         
      case UserVideo_VideoStereoscopyType_MONOSCOPIC:
         return Str_UserVideo_VideoStereoscopyType_MONOSCOPIC;
         
      case UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC:
         return Str_UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC;
         
      case UserVideo_VideoStereoscopyType_DUAL_FISHEYE:
         return Str_UserVideo_VideoStereoscopyType_DUAL_FISHEYE;
         
      case UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC:
         return Str_UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC;
         
      case UserVideo_VideoStereoscopyType_DEFAULT:
         break;
   }
   return Str_UserVideo_VideoStereoscopyType_DEFAULT;
}

+ (UserVideo_VideoStereoscopyType)userVideoStereoscopyTypeFromStr:(NSString *)videoStereoscopyType {
   if ([Str_UserVideo_VideoStereoscopyType_MONOSCOPIC isEqualToString:videoStereoscopyType]) {
      return UserVideo_VideoStereoscopyType_MONOSCOPIC;
   }
   if ([Str_UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC isEqualToString:videoStereoscopyType]) {
      return UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC;
   }
   if ([Str_UserVideo_VideoStereoscopyType_DUAL_FISHEYE isEqualToString:videoStereoscopyType]) {
      return UserVideo_VideoStereoscopyType_DUAL_FISHEYE;
   }
   if ([Str_UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC isEqualToString:videoStereoscopyType]) {
      return UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC;
   }
   return UserVideo_VideoStereoscopyType_DEFAULT;
   
}

static NSString const * Str_UserLiveEvent_Source_RTMP = @"rtmp";
static NSString const * Str_UserLiveEvent_Source_SEGMENTED_TS = @"segmented_ts";
static NSString const * Str_UserLiveEvent_Source_SEGMENTED_MP4 = @"segmented_mp4";

+ (NSString const *)userLiveEventSourceToStr:(UserLiveEvent_Source)source {
   switch (source) {
      case UserLiveEvent_Source_RTMP:
         return Str_UserLiveEvent_Source_RTMP;
      case UserLiveEvent_Source_SEGMENTED_TS:
         return Str_UserLiveEvent_Source_SEGMENTED_TS;
      case UserLiveEvent_Source_SEGMENTED_MP4:
         return Str_UserLiveEvent_Source_SEGMENTED_MP4;
   }
   return Str_UserLiveEvent_Source_RTMP;
}

+ (UserLiveEvent_Source)userLiveEventSourceFromStr:(NSString *)source {
   if ([Str_UserLiveEvent_Source_RTMP isEqualToString:source]) {
      return UserLiveEvent_Source_RTMP;
   }
   if ([Str_UserLiveEvent_Source_SEGMENTED_TS isEqualToString:source]) {
      return UserLiveEvent_Source_SEGMENTED_TS;
   }
   if ([Str_UserLiveEvent_Source_SEGMENTED_MP4 isEqualToString:source]) {
      return UserLiveEvent_Source_SEGMENTED_MP4;
   }
   return UserLiveEvent_Source_RTMP;
}


static NSString const * Str_UserLiveEvent_State_UNKNOWN = @"UNKNOWN";
static NSString const * Str_UserLiveEvent_State_LIVE_CREATED = @"LIVE_CREATED";
static NSString const * Str_UserLiveEvent_State_LIVE_CONNECTED = @"LIVE_CONNECTED";
static NSString const * Str_UserLiveEvent_State_LIVE_DISCONNECTED = @"LIVE_DISCONNECTED";
static NSString const * Str_UserLiveEvent_State_LIVE_FINISHED_ARCHIVED = @"LIVE_FINISHED_ARCHIVED";
static NSString const * Str_UserLiveEvent_State_LIVE_ACTIVE = @"LIVE_ACTIVE";
static NSString const * Str_UserLiveEvent_State_LIVE_ARCHIVING = @"LIVE_ARCHIVING";

+ (const NSString *)userLiveEventStateToStr:(UserLiveEvent_State)state {
   switch (state) {
         
      case UserLiveEvent_State_LIVE_CREATED:
         return Str_UserLiveEvent_State_LIVE_CREATED;
      case UserLiveEvent_State_LIVE_CONNECTED:
         return Str_UserLiveEvent_State_LIVE_CONNECTED;
      case UserLiveEvent_State_LIVE_DISCONNECTED:
         return Str_UserLiveEvent_State_LIVE_DISCONNECTED;
      case UserLiveEvent_State_LIVE_FINISHED_ARCHIVED:
         return Str_UserLiveEvent_State_LIVE_FINISHED_ARCHIVED;
      case UserLiveEvent_State_LIVE_ACTIVE:
         return Str_UserLiveEvent_State_LIVE_ACTIVE;
      case UserLiveEvent_State_LIVE_ARCHIVING:
         return Str_UserLiveEvent_State_LIVE_ARCHIVING;
      case UserLiveEvent_State_UNKNOWN:
         break;
         
   }
   return UserLiveEvent_State_UNKNOWN;
}

+ (UserLiveEvent_State)userLiveEventStateFromStr:(NSString *)state {
   if ([Str_UserLiveEvent_State_LIVE_CREATED isEqualToString:state]) {
      return UserLiveEvent_State_LIVE_CREATED;
   }
   if ([Str_UserLiveEvent_State_LIVE_CONNECTED isEqualToString:state]) {
      return UserLiveEvent_State_LIVE_CONNECTED;
   }
   if ([Str_UserLiveEvent_State_LIVE_DISCONNECTED isEqualToString:state]) {
      return UserLiveEvent_State_LIVE_DISCONNECTED;
   }
   if ([Str_UserLiveEvent_State_LIVE_FINISHED_ARCHIVED isEqualToString:state]) {
      return UserLiveEvent_State_LIVE_FINISHED_ARCHIVED;
   }
   if ([Str_UserLiveEvent_State_LIVE_ACTIVE isEqualToString:state]) {
      return UserLiveEvent_State_LIVE_ACTIVE;
   }
   if ([Str_UserLiveEvent_State_LIVE_ARCHIVING isEqualToString:state]) {
      return UserLiveEvent_State_LIVE_ARCHIVING;
   }
   
   return UserLiveEvent_State_UNKNOWN;
}

@end
