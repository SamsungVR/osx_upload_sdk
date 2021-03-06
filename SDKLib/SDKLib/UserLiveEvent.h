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


#import "VR.h"

@protocol User;

typedef NS_ENUM(NSInteger, UserLiveEvent_State) {
    
    UserLiveEvent_State_UNKNOWN,
    UserLiveEvent_State_LIVE_CREATED,
    UserLiveEvent_State_LIVE_CONNECTED,
    UserLiveEvent_State_LIVE_DISCONNECTED,
    UserLiveEvent_State_LIVE_FINISHED_ARCHIVED,
    UserLiveEvent_State_LIVE_ACTIVE,
    UserLiveEvent_State_LIVE_ARCHIVING
    
};

@protocol UserLiveEvent_Result_Delete <VR_Result_BaseCallback, VR_Result_SuccessCallback>


typedef NS_ENUM(NSInteger, UserLiveEvent_Result_Status_Delete) {
    
    USERLIVEEVENT_RESULT_STATUS_DELETE_INVALID_LIVE_EVENT_ID = 1
    
};

@end

@protocol UserLiveEvent_Result_Finish <VR_Result_BaseCallback, VR_Result_SuccessCallback>


typedef NS_ENUM(NSInteger, UserLiveEvent_Result_Status_Finish) {
    
    USERLIVEEVENT_RESULT_STATUS_FINISH_INVALID_LIVE_EVENT_ID = 1
    
};

@end

@protocol UserLiveEvent

typedef NS_ENUM(NSInteger, UserLiveEvent_Source) {
    UserLiveEvent_Source_RTMP,
    UserLiveEvent_Source_SEGMENTED_TS,
    UserLiveEvent_Source_SEGMENTED_MP4
};

- (NSString *)getId;
- (NSString *)getTitle;
- (NSString *)getDescription;
- (NSURL *)getProducerUrl;
- (NSURL *)getViewUrl;
- (UserVideo_VideoStereoscopyType)getVideoStereoscopyType;
- (UserLiveEvent_Source)getSource;
- (UserVideo_Permission)getPermission;
- (UserLiveEvent_State)getState;

- (id<User>)getUser;

- (bool)del:(id<UserLiveEvent_Result_Delete>)callback handler:(Handler)handler closure:(Object)closure;
- (bool)finish:(id<UserLiveEvent_Result_Finish>)callback handler:(Handler)handler closure:(Object)closure;

@end
