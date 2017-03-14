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

static const NSString *PROP_NAME = @"name";
static const NSString *PROP_PROFILE_PIC = @"profile_pic";
static const NSString *PROP_EMAIL = @"email";
static const NSString *PROP_SESSION_TOKEN = @"session_token";
static const NSString *PROP_USER_ID = @"user_id";

@implementation User_Impl

- (id)initWith:(APIClient_Impl *)apiClient jsonObject:(NSDictionary *)jsonObject {
    return [super initWithDict:jsonObject];
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

@end
