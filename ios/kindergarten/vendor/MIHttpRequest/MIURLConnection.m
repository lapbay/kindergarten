#import <objc/runtime.h>

#import "MIURLConnection.h"
#import "MBProgressHUD.h"

@interface MIURLConnectionOperation : NSOperation <NSURLConnectionDataDelegate> {
}

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) MIRequestFinishBlock finishBlock;
@property (strong, nonatomic) MIRequestErrorBlock errorBlock;
@property (strong, nonatomic) MIRequestUploadBlock uploadProgressBlock;
@property (strong, nonatomic) MIRequestDownloadBlock downloadProgressBlock;
@property (retain, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) NSURLResponse *response;
@property (assign, nonatomic) NSInteger expectedContentLength;
@property (strong, nonatomic) NSTimer *timeoutTimer;
@property (assign, nonatomic) NSTimeInterval timeoutDelay;
@property (assign, nonatomic) BOOL isExecuting;
@property (strong, nonatomic) NSRunLoop *currentRunLoop;

@end
//
//  MIURLConnection.m
//  requester
//
//  Created by Wu Chang on 12-2-27.
//  Copyright (c) 2012年 Milan. All rights reserved.
//

@implementation MIURLConnectionOperation
@synthesize connection, request, finishBlock, errorBlock, uploadProgressBlock, downloadProgressBlock, queue = _queue, data = _data, response = _response, expectedContentLength, isExecuting, currentRunLoop;

- (void)start {
    isExecuting = YES;
    self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];

    self.currentRunLoop = [NSRunLoop currentRunLoop];
    [self.connection scheduleInRunLoop:self.currentRunLoop forMode:NSDefaultRunLoopMode];
    
    self.timeoutTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(connectionTimeoutHandler:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timeoutTimer forMode:NSDefaultRunLoopMode];
    
    [self.connection start];
    [self.currentRunLoop run];
}

- (void)connectionTimeoutHandler:(NSTimer *)timer {
    self.timeoutDelay -= 1.0;
    if (self.timeoutDelay <= 0.0) {
        NSLog(@"timeout");
        [self operationWillFinish:[NSError errorWithDomain:@"Connection Timeout" code:-1 userInfo:[timer userInfo]]];
    }
}

- (void)operationWillFinish:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    });
    if (error && self.errorBlock) {
        MIRequestErrorBlock theErrorBlock = self.errorBlock;
        self.downloadProgressBlock = nil;
        
        [self.queue addOperationWithBlock:^{
            theErrorBlock(self.response, self.data, error);
        }];
    }

    if (self.timeoutTimer != nil) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    }
    
    [self.connection unscheduleFromRunLoop:self.currentRunLoop forMode:NSDefaultRunLoopMode];
    [self.connection cancel];
    self.connection = nil;
    [self cancel];
}


- (id)initWithRequest:(NSURLRequest *)req queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        if (!queue) queue = [NSOperationQueue mainQueue];
        self.queue = queue;
        self.request = req;
        self.timeoutDelay = 30.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        });
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)req queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler errorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))error{
    self = [self initWithRequest:req queue:queue];
    if (self) {
        self.finishBlock = handler;
        self.errorBlock = error;
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {    
    [self operationWillFinish:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (response.expectedContentLength > 0) {
        self.expectedContentLength = response.expectedContentLength;
        self.data = [NSMutableData dataWithCapacity:response.expectedContentLength];
    } else {
        self.data = [NSMutableData data];
    }
    
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
    if (self.downloadProgressBlock) {
        MIRequestDownloadBlock download = self.downloadProgressBlock;
        if (self.data.length == self.expectedContentLength) {
            self.downloadProgressBlock = nil;
        }
        
        [self.queue addOperationWithBlock:^{
            download(self.connection, self.data.length, self.expectedContentLength);
        }];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    MIRequestFinishBlock handler = self.finishBlock;
    self.finishBlock = nil;
    
    NSURLResponse *response = self.response;
    NSData *data = [self.data copy];
    
    [self.queue addOperationWithBlock:^{
        handler(response, data, nil);
    }];
    [self operationWillFinish:nil];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSCachedURLResponse *newCachedResponse = cachedResponse;
    if ([[[[cachedResponse response] URL] scheme] isEqual:@"https"]) {
        newCachedResponse = nil;
    } else {
        NSDictionary *newUserInfo;
        newUserInfo = [NSDictionary dictionaryWithObject:[[NSDate date] addTimeInterval:86400] forKey:@"Cached Date"];
        newCachedResponse = [[NSCachedURLResponse alloc]
                             initWithResponse:[cachedResponse response]
                             data:[cachedResponse data]
                             userInfo:newUserInfo
                             storagePolicy:[cachedResponse storagePolicy]];
    }
    return newCachedResponse;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (self.uploadProgressBlock) {
        MIRequestUploadBlock upload = self.uploadProgressBlock;
        if (totalBytesWritten == totalBytesExpectedToWrite) {
            self.uploadProgressBlock = nil;
        }
                
        [self.queue addOperationWithBlock:^{
            upload(self.connection, totalBytesWritten, totalBytesExpectedToWrite);
        }];
    }
}

@end

@implementation MIURLConnection

+ (void)sendAsynchronousRequest:(MIRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MIURLConnectionOperation *op = [[MIURLConnectionOperation alloc] initWithRequest:request queue:queue];
        op.finishBlock = handler;
        [op start];
	});
}

+ (void)sendAsynchronousRequest:(MIRequest *)request queue:(NSOperationQueue *)queue
              completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
                   errorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))error
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *cookie = [[userDefaults objectForKey:@"cookies"] objectForKey:MIAPIHost];
    NSString *current = [request.allHTTPHeaderFields objectForKey:@"Cookie"];
    if (current && cookie) {
        request.allHTTPHeaderFields = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@; %@", cookie, current] forKey:@"Cookie"];
    }else if (cookie) {
        request.allHTTPHeaderFields = [NSDictionary dictionaryWithObject:cookie forKey:@"Cookie"];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MIURLConnectionOperation *op = [[MIURLConnectionOperation alloc] initWithRequest:request queue:queue completionHandler:handler errorHandler:error];
        [op start];
	});
}

+ (void)sendAsynchronousRequest:(MIRequest *)request queue:(NSOperationQueue *)queue
              completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler
                   errorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler
                  uploadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))uploadHandler
                downloadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))downloadHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MIURLConnectionOperation *op = [[MIURLConnectionOperation alloc] initWithRequest:request queue:queue];
        op.finishBlock = finishHandler;
        op.errorBlock = errorHandler;
        op.uploadProgressBlock = uploadHandler;
        if (downloadHandler) {
            op.downloadProgressBlock = downloadHandler;
            op.expectedContentLength = 0;
        }
        [op start];
	});
}

@end
