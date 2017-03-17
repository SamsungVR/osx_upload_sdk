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


#import "UserLiveEvent_Impl.h"
#import "ClientWorkItem.h"

static const NSString
     * const PROP_ID = @"id",
     * const PROP_TITLE = @"title",
     * const PROP_PERMISSION = @"permission",
     * const PROP_SOURCE = @"source",
     * const PROP_STEREOSCOPIC_TYPE = @"stereoscopic_type",
     * const PROP_DESCRIPTION = @"description",
     * const PROP_INGEST_URL = @"ingest_url",
     * const PROP_VIEW_URL = @"view_url",
     * const PROP_STATE = @"state",
     * const PROP_THUMBNAIL_URL = @"thumbnail_url",
     * const PROP_VIEWER_COUNT = @"viewer_count",
     * const PROP_LIVE_STARTED = @"live_started",
     * const PROP_LIVE_STOPPED = @"live_stopped",
     * const PROP_METADATA_STEREOSCOPIC_TYPE = @"metadata_stereoscopic_type";

@interface WorkItemTypeDeleteLiveEvent : NSObject<AsyncWorkItemType>
@end

@interface WorkItemDeleteLiveEvent : ClientWorkItem

- (id)initWithClient:(APIClient_Impl *)apiClient;
- (void)set:(UserLiveEvent_Impl *)liveEvent callback:(id<UserLiveEvent_Result_Delete>)callback handler:(Handler)handler closure:(Object)closure;

@end


@implementation WorkItemTypeDeleteLiveEvent

- (AsyncWorkItem *)newInstance:(APIClient_Impl *)apiClient {
    return [[WorkItemDeleteLiveEvent alloc] initWithClient:apiClient];
}

@end

static id<AsyncWorkItemType> sTypeDeleteLiveEvent = nil;

@implementation WorkItemDeleteLiveEvent {
    UserLiveEvent_Impl *mUserLiveEvent;
}


- (id)initWithClient:(APIClient_Impl *)apiClient {
    return [super initWith:apiClient type:sTypeDeleteLiveEvent];
}

- (void)set:(UserLiveEvent_Impl *)userLiveEvent
   callback:(id<UserLiveEvent_Result_Delete>)callback handler:(Handler)handler closure:(Object)closure {
    
    [super set:callback handler:handler closure:closure];
    mUserLiveEvent = userLiveEvent;
}

- (void)onRun {
    id<HttpPlugin_GetRequest> request = nil;
    User_Impl *user = [mUserLiveEvent getUser];
    Headers headers = {
        HEADER_API_KEY, [[self getApiClient] getApiKey],
        HEADER_SESSION_TOKEN, [user getSessionToken],
        NULL
    };
    NSString *liveEventId = [mUserLiveEvent getId];
    
    NSString *userId = [user getUserId];
    request = [self newDeleteRequest:[NSString stringWithFormat:@"user/%@/video/%@", userId, liveEventId] headers:headers];
    if (!request) {
        [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_NULL_CONNECTION];
        return;
    }
    int responseCode = [self getResponseCode:request];
    if ([self isHttpSuccess:responseCode]) {
        [self dispatchSuccess];
        return;
    }
    NSData *response = [self readHttpStream:request debugMsg:nil];
    if (!response) {
        [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_STREAM_READ_FAILURE];
        return;
    }
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
    NSInteger status = [Util jsonOptInt:jsonResponse key:@"status" def:VR_RESULT_STATUS_SERVER_RESPONSE_NO_STATUS_CODE];
    [self dispatchFailure:status];
}

@end

@interface WorkItemTypeFinishLiveEvent : NSObject<AsyncWorkItemType>
@end

@interface WorkItemFinishLiveEvent : ClientWorkItem

- (id)initWithClient:(APIClient_Impl *)apiClient;
- (void)set:(UserLiveEvent_Impl *)liveEvent callback:(id<UserLiveEvent_Result_Delete>)callback handler:(Handler)handler closure:(Object)closure;

@end


@implementation WorkItemTypeFinishLiveEvent

- (AsyncWorkItem *)newInstance:(APIClient_Impl *)apiClient {
    return [[WorkItemFinishLiveEvent alloc] initWithClient:apiClient];
}

@end

static id<AsyncWorkItemType> sTypeFinishLiveEvent = nil;

@implementation WorkItemFinishLiveEvent {
    UserLiveEvent_Impl *mUserLiveEvent;
}


- (id)initWithClient:(APIClient_Impl *)apiClient {
    return [super initWith:apiClient type:sTypeFinishLiveEvent];
}

- (void)set:(UserLiveEvent_Impl *)userLiveEvent
   callback:(id<UserLiveEvent_Result_Finish>)callback handler:(Handler)handler closure:(Object)closure {
    
    [super set:callback handler:handler closure:closure];
    mUserLiveEvent = userLiveEvent;
}

- (void)onRun {
    id<HttpPlugin_PutRequest> request = nil;
    User_Impl *user = [mUserLiveEvent getUser];
    NSMutableDictionary *jsonParam = [[NSMutableDictionary alloc] init];
    jsonParam[@"state"] = @"LIVE_FINISHED_ARCHIVED";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonParam options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    Headers headers = {
        HEADER_CONTENT_LENGTH, [NSString stringWithFormat:@"%d", [jsonData length]],
        HEADER_CONTENT_TYPE, [NSString stringWithFormat:@"application/json%@", CONTENT_TYPE_CHARSET_SUFFIX_UTF8],
        HEADER_API_KEY, [[self getApiClient] getApiKey],
        HEADER_SESSION_TOKEN, [user getSessionToken],
        NULL
    };
    NSString *userId = [user getUserId];
    NSString *liveEventId = [mUserLiveEvent getId];

    request = [self newPutRequest:[NSString stringWithFormat:@"user/%@/video/%@", userId, liveEventId] headers:headers];
    if (!request) {
        [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_NULL_CONNECTION];
        return;
    }
    
    [self writeBytes:request data:jsonData debugMsg:nil];
    int responseCode = [self getResponseCode:request];
    if ([self isHttpSuccess:responseCode]) {
        [self dispatchSuccess];
        return;
    }
    NSData *response = [self readHttpStream:request debugMsg:nil];
    if (!response) {
        [self dispatchFailure:VR_RESULT_STATUS_HTTP_PLUGIN_STREAM_READ_FAILURE];
        return;
    }
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
    NSInteger status = [Util jsonOptInt:jsonResponse key:@"status" def:VR_RESULT_STATUS_SERVER_RESPONSE_NO_STATUS_CODE];
    [self dispatchFailure:status];
}

@end


@implementation UserLiveEvent_Impl

+ (void)initialize {
    sTypeDeleteLiveEvent = [[WorkItemTypeDeleteLiveEvent alloc] init];
    sTypeFinishLiveEvent = [[WorkItemTypeFinishLiveEvent alloc] init];
}

- (id)initWith:(User_Impl *)container jsonObject:(NSDictionary *)jsonObject {
    return [super initWithDict:jsonObject container:container];
}

- (id)initWithParams:(User_Impl *)container videoId:(NSString *)videoId title:(NSString *)title
    description:(NSString *)description
    permission:(UserVideo_Permission)permission source:(UserLiveEvent_Source)source
    videoSteroscopyType:(UserVideo_VideoStereoscopyType)videoStereoscopyType
    ingestUrl:(NSString *)ingestUrl viewUrl:(NSString *)viewUrl {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[PROP_ID] = videoId;
    dict[PROP_TITLE] = title;
    dict[PROP_DESCRIPTION] = description;
    dict[PROP_INGEST_URL] = ingestUrl;
    dict[PROP_VIEW_URL] = viewUrl;
    dict[PROP_STATE] = @"UNKNOWN";
    return [super initWithDict:dict container:container];
}


- (NSString *)getId {
    return [super getLocked:PROP_ID];
}

- (NSString *)getTitle {
    return [super getLocked:PROP_TITLE];
}

- (NSString *)getDescription {
    return [super getLocked:PROP_DESCRIPTION];
}

- (NSURL *)getProducerUrl {
    NSString *url = [super getLocked:PROP_INGEST_URL];
    if (!url) {
        return NULL;
    }
    return [NSURL URLWithString:url];
};

- (id<User>)getUser {
    return [self getContainer];
}

- (NSURL *)getViewUrl {
    NSString *url = [super getLocked:PROP_VIEW_URL];
    if (!url) {
        return NULL;
    }
    return [NSURL URLWithString:url];
}

- (UserLiveEvent_State)getState {
    NSString *state = [super getLocked:PROP_STATE];
    return [User_Impl userLiveEventStateFromStr:state];
}

- (UserVideo_Permission)getPermission {
    NSString *permission = [super getLocked:PROP_PERMISSION];
    return [User_Impl userVideoPermissionFromStr:permission];
}

- (UserVideo_VideoStereoscopyType)getVideoStereoscopyType {
    NSString *videoStereoscopyType = [super getLocked:PROP_STEREOSCOPIC_TYPE];
    return [User_Impl userVideoStereoscopyTypeFromStr:videoStereoscopyType];
}

- (UserLiveEvent_Source)getSource {
    NSString *source = [super getLocked:PROP_SOURCE];
    return [User_Impl userLiveEventSourceFromStr:source];
}

- (bool)del:(id<UserLiveEvent_Result_Delete>)callback handler:(Handler)handler closure:(Object)closure {
    User_Impl *user = [self getUser];
    AsyncWorkQueue *workQueue = [(APIClient_Impl *)[user getContainer] getAsyncWorkQueue];
    WorkItemDeleteLiveEvent *workItem = [workQueue obtainWorkItem:sTypeDeleteLiveEvent];
    [workItem set:self callback:callback handler:handler closure:closure];
    return [workQueue enqueue:workItem];
}

- (bool)finish:(id<UserLiveEvent_Result_Finish>)callback handler:(Handler)handler closure:(Object)closure {
    User_Impl *user = [self getUser];
    AsyncWorkQueue *workQueue = [(APIClient_Impl *)[user getContainer] getAsyncWorkQueue];
    WorkItemFinishLiveEvent *workItem = [workQueue obtainWorkItem:sTypeFinishLiveEvent];
    [workItem set:self callback:callback handler:handler closure:closure];
    return [workQueue enqueue:workItem];
}

@end
