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

#import "Compat_Defs.h"

typedef NS_ENUM(NSInteger, UserVideo_Permission) {
    UserVideo_Permission_PRIVATE,
    UserVideo_Permission_UNLISTED,
    UserVideo_Permission_PUBLIC,
    UserVideo_Permission_VR_ONLY,
    UserVideo_Permission_WEB_ONLY
};

typedef NS_ENUM(NSInteger, UserVideo_VideoStereoscopyType) {
    UserVideo_VideoStereoscopyType_DEFAULT,
    UserVideo_VideoStereoscopyType_MONOSCOPIC,
    UserVideo_VideoStereoscopyType_TOP_BOTTOM_STEREOSCOPIC,
    UserVideo_VideoStereoscopyType_LEFT_RIGHT_STEREOSCOPIC,
    UserVideo_VideoStereoscopyType_DUAL_FISHEYE
};

@protocol User_Result_UploadVideo;

@protocol UserVideo

/**
 * Cancel an ongoing upload. This yields the same result as calling User.cancelVideoUpload()
 *
 * @param closure An object that the application can use to uniquely identify this request.
 *                See callback documentation.
 * @return true if a cancel was scheduled, false if the upload could not be cancelled, which
 * can happen because the upload failed or completed even before the cancel could be reqeusted.
 */

- (bool)cancelUpload:(Object)closure;

/**
 * Retry a failed upload. The params are similar to those of User.uploadVideo. No check is
 * made to ensure that the parcel file descriptor points to the same file as the failed
 * upload.
 *
 *
 * @return true if a retry was scheduled, false if the upload is already in progress or cannot
 * be retried. An upload cannot be retried if it already completed successfully.
 */

- (bool)retryUpload:(NSInputStream *)source length:(long)length callback:(id<User_Result_UploadVideo>)callback
           handler:(Handler)handler closure:(Object)closure;

@end
