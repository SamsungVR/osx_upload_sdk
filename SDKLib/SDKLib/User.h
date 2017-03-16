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
#import "UserVideo.h"
#import "UserLiveEvent.h"

@protocol User_Result_CreateLiveEvent <VR_Result_BaseCallback, VR_Result_SuccessWithResultCallback>


typedef NS_ENUM(NSInteger, User_Result_Status_CreateLiveEvent) {
    
    USER_RESULT_STATUS_INVALID_STEREOSCOPIC_TYPE = 5,
    USER_RESULT_STATUS_INVALID_AUDIO_TYPE = 6
};

@end

@protocol User_Result_QueryLiveEvents <VR_Result_BaseCallback, VR_Result_SuccessWithResultCallback>

@end

@protocol User

- (NSString *)getName;
- (NSString *)getEmail;
- (NSURL *)getProfilePicUrl;
- (NSString *)getSessionToken;
- (NSString *)getUserId;

- (bool)createLiveEvent:(NSString *)title description:(NSString *)description
   permission:(UserVideo_Permission)permission source:(UserLiveEvent_Source)source
   videoStereoscopyType:(UserVideo_VideoStereoscopyType)videoStereoscopyType
   callback:(id<User_Result_CreateLiveEvent>)callback handler:(Handler)handler closure:(Object)closure;

- (bool)queryLiveEvents:(id<User_Result_QueryLiveEvents>)callback handler:(Handler)handler closure:(Object)closure;

@end

