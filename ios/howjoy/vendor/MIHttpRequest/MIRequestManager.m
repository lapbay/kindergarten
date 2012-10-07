//
//  MIRequestManager.m
//  requester
//
//  Created by Wu Chang on 12-2-29.
//  Copyright (c) 2012年 Milan. All rights reserved.
//

#import "MIRequestManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation MIRequestManager

static MIRequestManager *sharedRequestManager = nil;

+ (MIRequestManager *) requestManager
{
    if (sharedRequestManager == nil) {
        sharedRequestManager = [[super allocWithZone:NULL] init];
    }
    return sharedRequestManager;
}

+ (id)allocWithZone:(NSZone *)zone
{ 
    return [self requestManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void) fileLoader:(NSString *) imageURL withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withDownloadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))downloadHandler {
    MIRequest *request = [[MIRequest alloc] initWithURLString:imageURL];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    request.getParams = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"test", nil];
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:nil uploadHandler:nil downloadHandler:downloadHandler];
}

- (void) fileCacher:(NSString *) imageURL withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withDownloadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))downloadHandler {
    MIRequest *request = [[MIRequest alloc] initWithURLString:imageURL];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    request.getParams = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"test", nil];
    
    MICache *cache = [MICache currentCache];
    NSString *hash = [NSString stringWithFormat: @"%i",[imageURL hash]];
    if ([cache hasCacheForKey:hash]) {
        NSData *data = [cache dataForKey:hash];
        
        [self addOperationWithBlock:^{
            downloadHandler(nil, data.length, data.length);
        }];
 
        [self addOperationWithBlock:^{
            finishHandler(nil, data, nil);
        }];

    }else {
        [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:nil uploadHandler:nil downloadHandler:downloadHandler];
    }
}

- (BOOL) checkCache:(NSString *)key {
    MICache *cache = [MICache currentCache];
    NSString *hash = [NSString stringWithFormat: @"%i",[key hash]];
    if ([cache hasCacheForKey:hash]) {
        return YES;
    }else {
        return NO;
    }
}

- (void) cacheResponse:(NSString *)key withIndex:(NSNumber *)index isJson: (BOOL) isJson{
    MICache *cache = [MICache currentCache];
    NSString *hash = [NSString stringWithFormat: @"%i",[key hash]];
    NSData *data = [NSMutableData dataWithData: [cache dataForKey:hash]];
    NSMutableDictionary *response;
    if (isJson) {
        response = [NSMutableDictionary dictionaryWithDictionary: [data JSONValue]];
    }else {
        response = [NSMutableDictionary dictionaryWithObjectsAndKeys:data, @"data", nil];
    }
    //[self.delegate performSelector:@selector(connectionDidFinishLoading:) withObject:response];
}

- (void) fileUploader:(NSMutableDictionary *)files withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withUploadHandler:(void (^)(NSURLConnection*, NSInteger, NSInteger))uploadHandler {
    //    fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"data", @"key", @"sample.png", @"fileName", @"image/png", @"contentType", @"path", @"data", nil];    
    NSString *uri = [NSString stringWithFormat:@"%@/records.json", MIAPIHost];
//    NSString *uri = [NSString stringWithFormat:@"http://127.0.0.1/api/upload/"];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];    
    request.getParams = [self fetchAPIEnvironment];
    if ([files objectForKey:@"strings"]) {
        [request setPostStrings: [files objectForKey:@"strings"]];
    }
    if ([files objectForKey:@"files"]) {
        [request setPostDatas: [files objectForKey:@"files"]];
    }
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:nil uploadHandler:uploadHandler downloadHandler:nil];
}

+ (NSString*)md5HexDigest:(NSString *)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (NSString*)NSDataMD5HexDigest:(NSData *)input {
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(input.bytes, input.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (NSString*) mimeTypeForExtension: (NSString *) ext {
    ext = ext.lowercaseString;
    NSString *mimeType = @"application/octet-stream";
    if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) {
        mimeType = @"image/jpeg";
    }else if ([ext isEqualToString:@"png"]) {
        mimeType = @"image/png";
    }else if ([ext isEqualToString:@"gif"]) {
        mimeType = @"image/gif";
    }else if ([ext isEqualToString:@"tif"] || [ext isEqualToString:@"tiff"]) {
        mimeType = @"image/tiff";
    }

    return mimeType;
}

@end


@implementation MIRequestManager (fetchEnvironment)

- (NSMutableDictionary *) fetchAPIEnvironment {
    NSString *curVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"true", @"cdebug", curVer, @"cv", nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *info = [userDefaults objectForKey:@"user"];
    if (info) {
        if ([info objectForKey:@"token"]) {
            [result setObject:[info objectForKey:@"token"] forKey:@"auth_token"];
        }
    }
    return result;
}

@end

