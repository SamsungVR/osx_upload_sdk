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

#import "User.h"
#import "ObjBase.h"
#import "APIClient_Impl.h"

static const NSString * HEADER_SESSION_TOKEN = @"X-SESSION-TOKEN";

@interface User_Impl : ObjBase<User>

+ (NSString *)userVideoPermissionToStr:(UserVideo_Permission)permission;
+ (UserVideo_Permission)userVideoPermissionFromStr:(NSString *)permission;

+ (NSString *)userVideoStereoscopyTypeToStr:(UserVideo_VideoStereoscopyType)videoStereoscopyType;
+ (UserVideo_VideoStereoscopyType)userVideoStereoscopyTypeFromStr:(NSString *)videoStereoscopyType;

+ (NSString *)userLiveEventSourceToStr:(UserLiveEvent_Source)source;
+ (UserLiveEvent_Source)userLiveEventSourceFromStr:(NSString *)source;

+ (NSString *)userLiveEventStateToStr:(UserLiveEvent_State)state;
+ (UserLiveEvent_State)userLiveEventStateFromStr:(NSString *)state;

- (id)initWith:(APIClient_Impl *)apiClient jsonObject:(NSDictionary *)jsonObject;

@end
