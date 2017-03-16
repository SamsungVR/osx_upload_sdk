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

#import "User_Impl.h"
#import "ClientWorkItem.h"
#import "UserLiveEvent_Impl.h"

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
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    Headers headers = {
        HEADER_CONTENT_LENGTH, [NSString stringWithFormat:@"%d", [jsonData length]],
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
    int responseCode = [self getResponseCode:request];
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
                videoId:videoId title:mTitle description:mDescription permission:mPermission source:mSource videoSteroscopyType:mVideoStereoscopyType
                ingestUrl:ingestUrl viewUrl:viewUrl];
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
    int responseCode = [self getResponseCode:request];
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



@implementation User_Impl

+ (void)initialize {
    sTypeCreateLiveEvent = [[WorkItemTypeCreateLiveEvent alloc] init];
    sTypeQueryLiveEvents = [[WorkItemTypeQueryLiveEvents alloc] init];
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
    WorkItemCreateLiveEvent *workItem = [workQueue obtainWorkItem:sTypeCreateLiveEvent];
    [workItem set:self title:title description:description permission:permission source:source videoStereoscopyType:videoStereoscopyType
          callback:callback handler:handler closure:closure];
    return [workQueue enqueue:workItem];
}

- (bool)queryLiveEvents:(id<User_Result_QueryLiveEvents>)callback handler:(Handler)handler closure:(Object)closure {
    AsyncWorkQueue *workQueue = [(APIClient_Impl *)[super getContainer] getAsyncWorkQueue];
    WorkItemQueryLiveEvents *workItem = [workQueue obtainWorkItem:sTypeQueryLiveEvents];
    [workItem set:self callback:callback handler:handler closure:closure];
    return [workQueue enqueue:workItem];
}

+ (NSString *)userVideoPermissionToStr:(UserVideo_Permission)permission {
    switch (permission) {
        case UserVideo_Permission_PRIVATE:
            return @"Private";
        case UserVideo_Permission_UNLISTED:
            return @"Unlisted";
        case UserVideo_Permission_PUBLIC:
            return @"Public";
        case UserVideo_Permission_VR_ONLY:
            return @"VR Only";
        case UserVideo_Permission_WEB_ONLY:
            return @"Web Only";
    }
    return NULL;
}

+ (NSString *)userVideoStereoscopyTypeToStr:(UserVideo_VideoStereoscopyType)videoStereoscopyType {
    switch (videoStereoscopyType) {
            
        case UserVideo_VideoStereoscopyType_MONOSCOPIC:
            return @"monoscopic";
            
        case UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC:
            return @"left-right";
            
        case UserVideo_VideoStereoscopyType_DUAL_FISHEYE:
            return @"dual-fisheye";
            
        case UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC:
            return @"top-bottom";
    }
    return NULL;
}

+ (NSString *)userLiveEventSourceToStr:(UserLiveEvent_Source)source {
    switch (source) {
        case UserLiveEvent_Source_RTMP:
            return @"rtmp";
        case UserLiveEvent_Source_SEGMENTED_TS:
            return @"segmented_ts";
        case UserLiveEvent_Source_SEGMENTED_MP4:
            return @"segmented_mp4";
    }
    return NULL;
}

@end
