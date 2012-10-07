//
//  MIRequestManager.h
//  requester
//
//  Created by Wu Chang on 12-2-29.
//  Copyright (c) 2012年 Milan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIRequest.h"
#import "MIURLConnection.h"
#import "MICache.h"
#import "SBJson.h"

@protocol MIRequestDelegate <NSObject>

@required
@optional
- (void)connectionDidFinishLoading:(NSMutableDictionary *) response;
- (void)connection:(NSURLConnection *) connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *) connection totalBytesTransfered: (NSInteger) totalBytesTransfered totalBytesExpectedToTransfer: (NSInteger) totalBytesExpectedToTransfer;

@end

@interface MIRequestManager : NSOperationQueue

+ (MIRequestManager *)requestManager;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (BOOL) checkCache:(NSString *)key;
- (void) cacheResponse:(NSString *)key withIndex:(NSNumber *)index isJson: (BOOL) jsJson;
- (void) fileLoader:(NSString *) imageURL withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withDownloadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))downloadHandler;
- (void) fileCacher:(NSString *) imageURL withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withDownloadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))downloadHandler;
- (void) fileUploader:(NSMutableDictionary *)files withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withUploadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))uploadHandler;

+ (NSString*)md5HexDigest:(NSString *)input;
+ (NSString*)NSDataMD5HexDigest:(NSData *)input;
+ (NSString*) mimeTypeForExtension: (NSString *) ext;

//@property (strong, nonatomic) NSMutableArray *connections;
//@property (assign, nonatomic) BOOL useCache;

@end

@interface MIRequestManager (fetchEnvironment)
- (NSMutableDictionary *) fetchAPIEnvironment;
@end

