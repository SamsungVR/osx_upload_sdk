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

#import "HttpPlugin_RequestFactory_Impl.h"

static const NSString *sLog = @"HttpPlugin_RequestFactory_Impl";

@interface HttpPlugin_RequestFactory_Request : NSObject<HttpPlugin_ReadableWritableRequest>

@end

@implementation HttpPlugin_RequestFactory_Request {
    NSMutableURLRequest *mRequest;
    NSURLSession *mSession;
    NSHTTPURLResponse *mResponse;
    NSInputStream *mInputStream;
}

/* https://forums.developer.apple.com/thread/11519 */

+ (void)sendSynchronousRequest:(NSData * __autoreleasing *)result request:(NSURLRequest *)request
     returningResponse:(NSURLResponse * __autoreleasing *)responsePtr error:(NSError * __autoreleasing *)errorPtr {
    
    dispatch_semaphore_t    sem;
    
    sem = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             if (errorPtr != NULL) {
                 *errorPtr = error;
             }
             if (responsePtr != NULL) {
                 *responsePtr = response;
             }
             if (error == NULL) {
                 *result = [data copy];
             }  
             dispatch_semaphore_signal(sem);  
         }] resume];  
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);  
}

- (void)makeRequest {
    if (mInputStream) {
        return;
    }
    
    NSError *pError = NULL;
    NSData *pData = NULL;
    NSURLResponse *pResponse = NULL;
    [HttpPlugin_RequestFactory_Request sendSynchronousRequest:&pData
                      request:mRequest returningResponse:&pResponse error:&pError];
    if (!pData) {
        return;
    }
    mResponse = pResponse;
    mInputStream = [[NSInputStream alloc] initWithData:pData];
    
}

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url httpMethod:(NSString *)httpMethod headers:(Headers)headers {
    mSession = session;
    mResponse = NULL;
    mRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [mRequest setHTTPMethod:httpMethod];
    if (headers) {
        for (int i = 0; headers[i]; i += 2) {
            NSString *pAttr = headers[i + 0];
            NSString *pValue = headers[i + 1];
            [mRequest setValue:pAttr forHTTPHeaderField:pValue];
        }
    }
    return self;
}

- (NSInputStream *)input {
    [self makeRequest];
    return mInputStream;
}

- (void)output:(NSInputStream *)input buf:(uint8_t *)buf {
    mRequest.HTTPBodyStream = input;
    [self makeRequest];
}

- (int)responseCode {
    [self makeRequest];
    return mResponse.statusCode;
}

@end

@interface HttpPlugin_RequestFactory_GetRequest : HttpPlugin_RequestFactory_Request<HttpPlugin_GetRequest>

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url headers:(Headers)headers;

@end

@implementation HttpPlugin_RequestFactory_GetRequest

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url headers:(Headers)headers {
    return [super initWithSession:session url:url httpMethod:@"GET" headers:headers];
}

@end


@interface HttpPlugin_RequestFactory_PostRequest : HttpPlugin_RequestFactory_Request<HttpPlugin_PostRequest>

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url headers:(Headers)headers;

@end

@implementation HttpPlugin_RequestFactory_PostRequest

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url headers:(Headers)headers {
    return [super initWithSession:session url:url httpMethod:@"POST" headers:headers];
}

@end

@interface HttpPlugin_RequestFactory_PutRequest : HttpPlugin_RequestFactory_Request<HttpPlugin_PutRequest>

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url headers:(Headers)headers;

@end

@implementation HttpPlugin_RequestFactory_PutRequest

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url headers:(Headers)headers {
    return [super initWithSession:session url:url httpMethod:@"PUT" headers:headers];
}

@end

@interface HttpPlugin_RequestFactory_DeleteRequest : HttpPlugin_RequestFactory_Request<HttpPlugin_DeleteRequest>

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url headers:(Headers)headers;

@end

@implementation HttpPlugin_RequestFactory_DeleteRequest

- (id)initWithSession:(NSURLSession *)session url:(NSString *)url headers:(Headers)headers {
    return [super initWithSession:session url:url httpMethod:@"DELETE" headers:headers];
}

@end

@implementation HttpPlugin_RequestFactory_Impl {
    NSURLSession *mSession;
}

- (id)init {
    NSURLSessionConfiguration *ephemeralConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    mSession = [NSURLSession sessionWithConfiguration:ephemeralConfiguration delegate:nil delegateQueue:nil];
    return [super init];
}

- (id<HttpPlugin_GetRequest>)newGetRequest:(NSString *)url headers:(Headers)headers {
    return [[HttpPlugin_RequestFactory_GetRequest alloc] initWithSession:mSession url:url headers:headers];
}

- (id<HttpPlugin_PostRequest>)newPostRequest:(NSString *)url headers:(Headers)headers {
    return [[HttpPlugin_RequestFactory_PostRequest alloc] initWithSession:mSession url:url headers:headers];
}

- (id<HttpPlugin_DeleteRequest>)newDeleteRequest:(NSString *)url headers:(Headers)headers {
    return [[HttpPlugin_RequestFactory_DeleteRequest alloc] initWithSession:mSession url:url headers:headers];
}

- (id<HttpPlugin_PutRequest>)newPutRequest:(NSString *)url headers:(Headers)headers {
    return [[HttpPlugin_RequestFactory_PutRequest alloc] initWithSession:mSession url:url headers:headers];
}

- (void)destroy {
}


@end
