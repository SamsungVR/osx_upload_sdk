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

/**
 * Assume class X is your implementation of BaseRequest or any of its descendant interfaces.
 * Let m be an instance of X, that is X m = new X();
 * m will be touched from only one thread. This thread may not be the UI thread.
 * Let n be an instance of X, that is X n = new X();
 * m and n could be in parallel use in different threads.
 */

@protocol HttpPlugin_BaseRequest

/**
 * Destroy this request object. Cleanup any HTTP resources here.
 *
 * @throws Exception
 */

- (void)destroy;

@end

/**
 * A request that allows reading from the server.
 */

@protocol HttpPlugin_ReadableRequest <HttpPlugin_BaseRequest>

/**
 * Used by the SDK to read data from the server.
 *
 * @return an InputStream from which server data can be read
 * @throws Exception
 */

- (NSInputStream *)input;

/**
 * Response code for this request
 *
 * @return an HTTP resoponse code
 */

- (int)responseCode;

@end

/**
 * A request that allows writing to the server
 */

@protocol HttpPlugin_WritableRequest <HttpPlugin_BaseRequest>

/**
 * This method is called by the SDK requesting the plugin to copy data from the
 * provided input stream to the HTTP socket - i.e. send data to the server.
 *
 * @param input The input stream from which data must be read and written to the HTTP
 *              socket
 * @param buf This is a helper byte buffer. The application can use this buffer for
 *            reading from the input stream and writing to the HTTP socket. This
 *            is usually a per-thread buffer maintained by the SDK, and hence is much
 *            cheaper to use than allocating a new buffer for every write request.  This
 *            is also appropriately sized for the task at hand. For example, to
 *            send a large file, this could be a 1MB buffer.  For sending JSON, could
 *            be 1KB buffer.
 */

- (void)output:(NSInputStream *)input buf:(uint8_t *)buf;

@end

/**
 * A request that allows bi-drectional ordered communication.  Writes happen before reads.
 */

@protocol HttpPlugin_ReadableWritableRequest <HttpPlugin_ReadableRequest, HttpPlugin_WritableRequest>
@end


/**
 * A HTTP Get request
 */

@protocol HttpPlugin_GetRequest <HttpPlugin_ReadableRequest>
@end

/**
 * A HTTP Post request
 */

@protocol HttpPlugin_PostRequest <HttpPlugin_ReadableWritableRequest>
@end

/**
 * A HTTP Delete request
 */

@protocol HttpPlugin_DeleteRequest <HttpPlugin_ReadableRequest>
@end

/**
 * A HTTP Put request
 */

@protocol HttpPlugin_PutRequest <HttpPlugin_ReadableWritableRequest>
@end

/**
 * A factory interface that allows creation of HTTP Get, Post, Put and Delete requests.
 * These methods will be called from any thread; the implementation MUST be thread safe.
 * The implementation MUST establish a HTTP connection to url, and send the http headers on that
 * request. The http headers for the most part will contain the content-length.  If content-length
 * is missing, it means that chunked mode is desired.  The headers provided here are all
 * that are needed by the server to respond.  The implementation does not need to
 * add any additional headers.
 */

@protocol HttpPlugin_RequestFactory

- (id<HttpPlugin_GetRequest>)newGetRequest:(NSString *)url headers:(NSString * __autoreleasing *)headers;
- (id<HttpPlugin_PostRequest>)newPostRequest:(NSString *)url headers:(NSString * __autoreleasing *)headers;
- (id<HttpPlugin_DeleteRequest>)newDeleteRequest:(NSString *)url headers:(NSString * __autoreleasing *)headers;
- (id<HttpPlugin_PutRequest>)newPutRequest:(NSString *)url headers:(NSString * __autoreleasing *)headers;

@end





