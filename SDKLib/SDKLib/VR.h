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

#import <Foundation/Foundation.h>
#import "Compat_Defs.h"
#import "HttpPlugin.h"

/**
 * These status codes are common across all requests.  Some of them, for example
 * STATUS_MISSING_API_KEY, STATUS_INVALID_API_KEY are not meant for the end user.
 */

#define STATUS_HTTP_BASE (1 << 16)
#define STATUS_SERVER_RESPONSE_BASE (2 << 16)
#define STATUS_SDK_BASE (3 << 16)

typedef NS_ENUM(NSInteger, VR_Result_Status) {
    /**
     * User id in HTTP header is invalid
     */
    
    VR_RESULT_STATUS_INVALID_USER_ID = 1002,
    
    /**
     * Session token in HTTP header is missing or invalid
     */
    
    VR_RESULT_STATUS_MISSING_X_SESSION_TOKEN_HEADER = 1003,
    VR_RESULT_STATUS_INVALID_SESSION = 1004,

    /**
     * API key in HTTP header is missing or invalid
     */
    
    VR_RESULT_STATUS_MISSING_API_KEY = 1005,
    VR_RESULT_STATUS_INVALID_API_KEY = 1006,
    
    /**
     * Http Plugin returned a NULL connection object
     */
    
    VR_RESULT_STATUS_HTTP_PLUGIN_NULL_CONNECTION = STATUS_HTTP_BASE | 1,
    
    /**
     * Http Plugin provided input stream for reading server responses could not be read
     */
    
    VR_RESULT_STATUS_HTTP_PLUGIN_STREAM_READ_FAILURE = STATUS_HTTP_BASE | 2,
    
    /**
     * We were unable to process the server response json. Possible causes are response
     * did not contain JSON, or JSON is missing important data
     */
    VR_RESULT_STATUS_SERVER_RESPONSE_INVALID = STATUS_SERVER_RESPONSE_BASE | 1,
    
    /**
     * The server returned a HTTP Error code, but no JSON based status was found.
     */
    
    VR_RESULT_STATUS_SERVER_RESPONSE_NO_STATUS_CODE = STATUS_SERVER_RESPONSE_BASE | 2,
    
    /**
     * This feature is not supported
     */
    
    VR_RESULT_STATUS_FEATURE_NOT_SUPPORTED = STATUS_SDK_BASE | 1
    
};


@protocol VR_Result_SuccessCallback

/**
 * The request was successful
 *
 * @param closure Application provided object used to identify this request.
 */
    
- (void)onSuccess:(Object)closure;

@end

@protocol VR_Result_FailureCallback

/**
 * The request failed
 *
 * @param closure Application provided object used to identify this request.
 * @param status The reason for failure. These are specific to the request. The callback
 *               interface for the request will have these defined.  Also, status'es
 *               common for any request, from VR.Result could also be provided here.
 */

- (void)onFailure:(Object)closure status:(NSInteger)status;

@end

/**
 * Base interface for other result callback groups.
 */

@protocol VR_Result_BaseCallback <VR_Result_FailureCallback>
    
/**
 * This request was cancelled.  The request is identified by the closure param.
 *
 * @param closure Application provided object used to identify this request.
 */

- (void)onCancelled:(Object)closure;
    
/**
 * This request resulted in an exception.  Some exceptions can be analyzed to take
 * corrective actions.  For example:  if HTTP Socket Write timeout is a user configurable
 * param, the application should examine the exception to see if it is a SocketWriteTimeout
 * exception.  If so, the user could be prompted to increase the timeout value.
 *
 * In other cases, the application should log these exceptions for review by
 * engineering.
 *
 * @param closure Application provided object used to identify this request.
 */

- (void)onException: (Object)closure  ex:(Exception)ex;
    
@end


/**
 * A callback used to notify progress of a long running request
 */

@protocol VR_Result_ProgressCallback

    /**
     * The latest progress update.  There are two callback methods. One in which
     * the progress percent could be determined. The other in which the progress
     * percentage could not be determined and the processed value is provided as is.
     *
     * @param closure Application provided object used to identify this request.
     * @param progressPercent Progress percentage between 0.0 to 100.0
     */
    
- (void)onProgress:(Object)closure progressPercent:(float)progressPercent complete:(long)complete max:(long)max;
- (void)onProgress:(Object)closure complete:(long)complete;
    
@end


@protocol VR_Result_SuccessWithResultCallback
    
/**
 * The request was successful and a result object was located or created
 *
 * @param result The object created or located for the request made
 * @param closure Application provided object used to identify this request.
 */

- (void)onSuccess:(Object)closure result:(id)result;

@end


/**
 * Callback for the getUserBySessionId request. The success callback has result
 * of type User
 */

@protocol VR_Result_GetUserBySessionId <VR_Result_BaseCallback, VR_Result_SuccessWithResultCallback>
@end

/**
 * Callback for the getUserBySessionToken request. The success callback has result
 * of type User
 */

@protocol VR_Result_GetUserBySessionToken <VR_Result_BaseCallback, VR_Result_SuccessWithResultCallback>
@end



@protocol VR_Result_Login <VR_Result_BaseCallback, VR_Result_SuccessWithResultCallback>

typedef NS_ENUM(NSInteger, VR_Result_Status_Login) {
    VR_RESULT_STATUS_LOGIN_MISSING_EMAIL_OR_PASSWORD = 1,
    VR_RESULT_STATUS_LOGIN_ACCOUNT_LOCKED_EXCESSIVE_FAILED_ATTEMPTS = 2,
    VR_RESULT_STATUS_LOGIN_ACCOUNT_WILL_BE_LOCKED_OUT = 3,
    VR_RESULT_STATUS_LOGIN_ACCOUNT_NOT_YET_ACTIVATED = 4,
    VR_RESULT_STATUS_LOGIN_UNKNOWN_USER = 5,
    VR_RESULT_STATUS_LOGIN_LOGIN_FAILED = 6,
    VR_RESULT_STATUS_USER_WITH_EMAIL_ALREADY_EXISTS = 7
};

@end

@protocol VR_Result_NewUser <VR_Result_BaseCallback, VR_Result_SuccessWithResultCallback>

typedef NS_ENUM(NSInteger, VR_Result_Status_NewUser) {
    VR_RESULT_STATUS_NEWUSER_MISSING_EMAIL_OR_PASSWORD = 1,
    VR_RESULT_STATUS_NEWUSER_NAME_TOO_SHORT_LESS_THAN_3_CHARS = 2,
    VR_RESULT_STATUS_NEWUSER_PASSWORD_TOO_WEAK = 3,
    VR_RESULT_STATUS_NEWUSER_EMAIL_BAD_FORM = 4,
    VR_RESULT_STATUS_NEWUSER_PASSWORD_CANNOT_CONTAIN_EMAIL = 5,
    VR_RESULT_STATUS_NEWUSER_PASSWORD_CANNOT_CONTAIN_USERNAME = 6,
};

@end

@protocol VR_Result_Init <VR_Result_SuccessCallback, VR_Result_FailureCallback>
@end

@protocol VR_Result_Destroy <VR_Result_SuccessCallback, VR_Result_FailureCallback>
@end

@protocol VR_Result
@end

@interface VR : NSObject

+ (bool)initAsync:(NSString *)endPoint apiKey:(NSString *)apiKey
    factory:(id<HttpPlugin_RequestFactory>)factory
    callback:(id<VR_Result_Init>)callback
    handler:(NSOperationQueue *)handler closure:(Object)closure;

+ (bool)initAsync:(NSString *)endPoint apiKey:(NSString *)apiKey
    callback:(id<VR_Result_Init>)callback
    handler:(NSOperationQueue *)handler closure:(Object)closure;

+ (bool)destroyAsync:(id<VR_Result_Destroy>)callback handler:(NSOperationQueue *)handler
              closure:(Object)closure;


@end
