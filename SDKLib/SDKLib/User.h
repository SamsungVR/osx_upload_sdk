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

@protocol User_Result_UploadVideo <VR_Result_BaseCallback, VR_Result_ProgressCallback, VR_Result_SuccessWithResultCallback>


/**
 * Callback delivering results of uploadVideo. Most status codes
 * are self explanatory. The non-obvious ones are documented.
 */

typedef NS_ENUM(NSInteger, User_Result_Status_UploadVideo) {
   
   STATUS_OUT_OF_UPLOAD_QUOTA = 1,
   STATUS_BAD_FILE_LENGTH = 3,
   STATUS_FILE_LENGTH_TOO_LONG = 4,
   STATUS_INVALID_STEREOSCOPIC_TYPE = 5,
   STATUS_INVALID_AUDIO_TYPE = 6,
   
   STATUS_CHUNK_UPLOAD_FAILED = 101,
   
   /**
    * An attempt to query the url for the next chunk upload failed.
    */
   STATUS_SIGNED_URL_QUERY_FAILED = 102,
   
   /**
    * An attempt to schedule the content upload onto a background
    * thread failed. This may indicate that the system is low on resources.
    * The user could attempt to kill unwanted services/processess and retry
    * the upload operation
    */
   
   STATUS_CONTENT_UPLOAD_SCHEDULING_FAILED = 103,
   
   /**
    * The file has been modified while the upload was in progress. This could
    * be a checksum mismatch or file length mismatch.
    */
   
   STATUS_FILE_MODIFIED_AFTER_UPLOAD_REQUEST = 104
};

/**
 * The server issued a video id for this upload.  The contents
 * of the video may not have been uploaded yet.
 */

- (void)onVideoIdAvailable:(Object)closure video:(id<UserVideo>)video;

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


- (bool)uploadVideo:(NSInputStream *)source length:(long)length title:(NSString *)title description:(NSString *)description
         permission:(UserVideo_Permission)permission callback:(id<User_Result_UploadVideo>)callback
            handler:(Handler)handler closure:(Object)closure;


- (bool)cancelUploadVideo:(Object)closure;


@end

