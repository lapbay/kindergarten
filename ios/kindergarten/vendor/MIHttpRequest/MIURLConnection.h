//
//  MIURLConnection.h
//  requester
//
//  Created by Wu Chang on 12-2-27.
//  Copyright (c) 2012年 Milan. All rights reserved.
//

#ifdef DEBUG
//#define MIAPIHost @"http://localhost:3000/api"
#define MIAPIHost @"http://10.0.0.15:3000/api"
#else
#define MIAPIHost @"http://211.144.37.205/api"
#endif

typedef void (^MIRequestFinishBlock)(NSURLResponse*, NSData*, NSError*);
typedef void (^MIRequestErrorBlock)(NSURLResponse*, NSData*, NSError*);
typedef void (^MIRequestUploadBlock)(NSURLConnection*, NSInteger, NSInteger);
typedef void (^MIRequestDownloadBlock)(NSURLConnection*, NSInteger, NSInteger);

#import <Foundation/Foundation.h>
#import "MIRequest.h"

@interface MIURLConnection : NSURLConnection

+ (void)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;

+ (void)sendAsynchronousRequest:(MIRequest *)request queue:(NSOperationQueue *)queue
              completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
                   errorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))error;

+ (void)sendAsynchronousRequest:(MIRequest *)request queue:(NSOperationQueue *)queue
              completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler
                   errorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler
                  uploadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))uploadHandler
                downloadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))downloadHandler;

@end
