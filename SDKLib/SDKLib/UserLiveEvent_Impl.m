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


@implementation UserLiveEvent_Impl

- (id)initWith:(User_Impl *)container jsonObject:(NSDictionary *)jsonObject {
    return [super initWithDict:jsonObject container:container];
}

@end
