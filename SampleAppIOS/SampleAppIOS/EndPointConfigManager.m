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

#import "EndPointConfigManager.h"
#import "DgApp.h"

static NSString *CFG_FILE_URL = @"cfgFileURL";
static NSString *JSON_ITEMS = @"items";
static NSString *CFG_ID = @"id";
static NSString *CFG_ENDPOINT = @"endpoint";
static NSString *CFG_API_KEY = @"apikey";
static NSString *CFG_SELECTED = @"selected";
static NSString *CFG_SSO_APP_ID = @"ssoappid";
static NSString *CFG_SSO_APP_SECRET = @"ssoappsecret";

@implementation EndPointConfigManager {
    NSMutableArray *mConfigList;
    NSString *mSelectedId;
    DgApp *mApp;
}

- (id)initWithApp:(DgApp *)app {
    mApp = app;
    mConfigList = [[NSMutableArray alloc] init];
    [self loadJsonConfig];
    return [super init];
}

- (EndPointConfig *)getConfig:(NSString *)identifier {
    NSUInteger len = [mConfigList count];
    for (NSUInteger i = 0; i < len; i += 1) {
        EndPointConfig *epCfg = [mConfigList objectAtIndex:i];
        NSString *pIdentifier = [epCfg getId];
        if ([pIdentifier isEqualToString:identifier]) {
            return epCfg;
        }
    }
    return NULL;
}

- (void)selectConfigById:(NSString *)argId {
    if (argId && [argId isEqualToString:mSelectedId]) {
        return;
    }
    mSelectedId = argId;
    [self onConfigChanged];
}

- (bool)selectConfigByIndex:(NSInteger)index {
    if (index < 0 || index >= [mConfigList count]) {
        return false;
    }
    EndPointConfig *cfg = [mConfigList objectAtIndex:index];
    NSString *cid = [cfg getId];
    if (mSelectedId && [mSelectedId isEqualToString:cid]) {
        return false;
    }
    mSelectedId = cid;
    [self onConfigChanged];
    return true;
}


- (bool)deleteConfigByIndex:(NSInteger)index {
    if (index >= 0 && index < [mConfigList count]) {
        [mConfigList removeObjectAtIndex:index];
        [self onConfigChanged];
        return true;
    }
    return false;
}

- (EndPointConfig *)getSelectedConfig {
    if (!mSelectedId) {
        return NULL;
    }
    return [self getConfig:mSelectedId];
}

- (NSInteger)getSelectedIndex {
    if (mSelectedId) {
        for (NSInteger i = [mConfigList count] - 1; i >= 0; i -= 1) {
            EndPointConfig *cfg = [mConfigList objectAtIndex:i];
            if ([mSelectedId isEqualToString:[cfg getId]]) {
                return i;
            }
        }
    }
    return -1;
}

- (NSString *)getDefaultCfgURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"vrsdfcfg.json"];
    NSLog(@"filePath %@", filePath);
    return filePath;
}

- (void)onConfigChanged {
    NSUInteger len = [mConfigList count];
    NSString *matchedId = NULL, *firstSelectedId = NULL;

    for (NSUInteger i = 0; i < len; i += 1){
        EndPointConfig *epCfg = [mConfigList objectAtIndex:i];
        NSString *epId = [epCfg getId];
        if (!firstSelectedId) {
            firstSelectedId = epId;
        }
        if (epId  && [epId isEqualToString:mSelectedId]) {
            matchedId = epId;
        }
    }
    if (!matchedId) {
        matchedId = firstSelectedId;
    }
    mSelectedId = matchedId;

}

- (NSArray *)getList {
    return mConfigList;
}

- (NSUInteger)getCount {
    return [mConfigList count];
}

- (bool)loadJsonConfig {
    [mConfigList removeAllObjects];
    mSelectedId = NULL;


    NSString *cfgFileUrl = [self getDefaultCfgURL];

    NSData *pJsonData = [[NSData alloc] initWithContentsOfFile:cfgFileUrl];
    if (!pJsonData) {
        return false;
    }
    id result = [NSJSONSerialization JSONObjectWithData:pJsonData options:0 error:nil];
    if (!result) {
        return false;
    }
    NSString *selectedId = result[CFG_SELECTED];

    id items = result[JSON_ITEMS];
    for (NSString *key in items) {
        id cfgBlock = items[key];
        NSString *identifier = cfgBlock[CFG_ID];
        NSString *apiKey = cfgBlock[CFG_API_KEY];
        NSString *endPoint = cfgBlock[CFG_ENDPOINT];
        //NSString *ssoAppId = cfgBlock[CFG_SSO_APP_ID];
        //NSString *ssoAppSecret = cfgBlock[CFG_SSO_APP_SECRET];

        if (identifier && [identifier isEqualToString:selectedId]) {
            mSelectedId = identifier;
        }
        EndPointConfig *epCfg = [[EndPointConfig alloc] initWithId:identifier];
        [epCfg setUrl:endPoint];
        [epCfg setApiKey:apiKey];

        [mConfigList addObject:epCfg];

    }
    [self onConfigChanged];
    return true;
}

- (bool)saveJsonConfig {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *items = [[NSMutableDictionary alloc] init];
    result[JSON_ITEMS] = items;
    NSString *selectedId = mSelectedId, *matchedSelectedId = NULL, *firstId = NULL;

    NSUInteger len = [mConfigList count];
    for (NSUInteger i = 0; i < len; i += 1) {
        EndPointConfig *epCfg = [mConfigList objectAtIndex:i];
        NSString *identifier = [epCfg getId];
        if (!firstId) {
            firstId = identifier;
        }
        if ([identifier isEqualToString:selectedId]) {
            matchedSelectedId = identifier;
        }
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        item[CFG_ID] = identifier;
        item[CFG_ENDPOINT] = [epCfg getUrl];
        item[CFG_API_KEY] = [epCfg getApiKey];
        items[identifier] = item;
    }
    if (!matchedSelectedId) {
        matchedSelectedId = firstId;
    }
    if (matchedSelectedId) {
        result[CFG_SELECTED] = matchedSelectedId;
    }
    NSString *cfgFileUrl = [self getDefaultCfgURL];
    NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:cfgFileUrl append:NO];
    [stream open];
    bool success = (0 != [NSJSONSerialization writeJSONObject:result toStream:stream options:NSJSONWritingPrettyPrinted error:nil]);
    [stream close];
    return success;
}

- (void)deleteConfig:(NSString *)argId {
    NSUInteger len = [mConfigList count];
    for (NSInteger i = len - 1; i >= 0; i -= 1) {
        EndPointConfig *epCfg = [mConfigList objectAtIndex:i];
        NSString *identifier = [epCfg getId];
        if ([identifier isEqualToString:argId]) {
            [mConfigList removeObjectAtIndex:i];
            break;
        }
    }
    [self onConfigChanged];
}

- (bool)addOrUpdateConfig:(EndPointConfig *)config {
    NSString *identifier = [config getId];
    if (!identifier) {
        return false;
    }
    EndPointConfig *existing = [self getConfig:identifier];
    if (!existing) {
        [mConfigList addObject:config];
    } else {
        if (existing != config) {
            [existing setApiKey:[config getApiKey]];
            [existing setUrl:[config getUrl]];
        }
    }
    [self onConfigChanged];
    return true;
}

@end
