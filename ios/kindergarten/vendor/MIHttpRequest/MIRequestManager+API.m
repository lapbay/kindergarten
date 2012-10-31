//
//  MIRequestManager+API.m
//  requester
//
//  Created by Wu Chang on 12-3-1.
//  Copyright (c) 2012年 Milan. All rights reserved.
//

#import "MIRequestManager+API.h"

@implementation MIRequestManager (sampleAPI)

- (void) apiSampleDelegate:(NSString *) url withIndex: (NSString *)index withDelegate: (NSObject <MIRequestDelegate> *) delegate{
    NSString *uri = [NSString stringWithFormat:@"%@/api/sample/", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"]; 
    NSString* path = [NSString stringWithFormat: @"%@/%@", docPath, @"cloud.png"];
    NSDictionary *fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"data", @"key", @"sample.png", @"fileName", @"image/png", @"contentType", path, @"data", nil];
    
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    request.getParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"true", @"text", @"中文", @"key", nil];
    //request.postStrings = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"google.com", @"domain", @"baidu.com", @"name", nil];
    request.postDatas = [NSMutableDictionary dictionaryWithObjectsAndKeys:fileInfo, @"data", nil];
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             NSLog(@"in manager %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         }else if ([data length] == 0 && error == nil){
             //[delegate emptyReply];
         }else if (error != nil && error.code == NSURLErrorTimedOut){
             //[delegate timedOut];
             NSLog(@"%@",@"timeout");
         }else if (error != nil){
             //[delegate downloadError:error];
         }
     }];
}


- (void) apiSampleBlock:(NSString *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/api/sample/", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
    NSString* path = [NSString stringWithFormat: @"%@/%@", docPath, @"cloud.png"];
    NSDictionary *fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"data", @"key", @"sample.png", @"fileName", @"image/png", @"contentType", path, @"data", nil];
    
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    request.getParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"true", @"text", @"中文", @"key", nil];
    //request.postStrings = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"google.com", @"domain", @"baidu.com", @"name", nil];
    request.postDatas = [NSMutableDictionary dictionaryWithObjectsAndKeys:fileInfo, @"data", nil];
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

//[manager apiSampleBlock:@"url" withFinishHandler:^(NSURLResponse *response, NSData *data, NSError *error)
// {
//     if ([data length] > 0 && error == nil){
//         NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[data JSONValue]];
//         dispatch_async(dispatch_get_main_queue(), ^{
//             //something;
//         });
//     }
// } withDownloadHandler:^(NSURLResponse *response, NSData *data, NSError *error)
// {
//     dispatch_async(dispatch_get_main_queue(), ^{
//         //something;
//     });
// }];

@end

@implementation MIRequestManager (appAPI)

- (void) apiUserLogin:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/users/sign_in.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    request.getParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"iOSClient", @"from", nil];
    NSMutableDictionary *postStrings = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [postStrings addEntriesFromDictionary:url];
    }
    request.postStrings = postStrings;

    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiUserLogout:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/users/sign_out.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"DELETE";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;

    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiProfile:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiFriendsList:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/%@/friendships.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiSendMessage:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/messages.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *postStrings = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [postStrings addEntriesFromDictionary:url];
    }
    request.postStrings = postStrings;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiInviteFriends:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/notifications.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *postStrings = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [postStrings addEntriesFromDictionary:url];
    }
    request.postStrings = postStrings;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiSearches:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/searches.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *postStrings = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [postStrings addEntriesFromDictionary:url];
    }
    request.postStrings = postStrings;
    Log(@"%@", postStrings);
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiFriendRequest:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/%@/friendships.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiFriendResponse:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/self/friendships/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"PUT";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiFriendRemove:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/self/friendships/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"DELETE";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiMessageCenter:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/messages.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiNotificationCenter:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/notifications.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiFeedCenter:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/feeds.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiFeedInfo:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/feeds/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}


- (void) apiSendFeed:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/feeds.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *postStrings = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [postStrings addEntriesFromDictionary:url];
    }
    request.postStrings = postStrings;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiUserTasks:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/%@/tasks.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiTaskCenter:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/tasks.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiTaskCreate:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/tasks.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";

    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *postStrings = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [postStrings addEntriesFromDictionary:url];
    }
    request.postStrings = postStrings;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiTaskInfo:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/tasks/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";

    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiTaskUpdate:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/tasks/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"PUT";

    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiJoinTask:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/self/tasks.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *postStrings = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [postStrings addEntriesFromDictionary:url];
    }
    request.postStrings = postStrings;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiDoingTask:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/self/tasks/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"PUT";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiFinishTask:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/self/tasks/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"DELETE";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiRecordTask:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/records.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *postStrings = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [postStrings addEntriesFromDictionary:url];
    }
    request.postStrings = postStrings;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiFindProps:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/props.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiUserProps:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/profiles/self/props/%@.json", MIAPIHost, [url objectForKey:@"id"]];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"GET";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

- (void) apiUnlockCoupons:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler {
    NSString *uri = [NSString stringWithFormat:@"%@/coupons.json", MIAPIHost];
    MIRequest *request = [[MIRequest alloc] initWithURLString:uri];
    request.HTTPMethod = @"POST";
    
    request.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1.0", @"APIVersion", @"gzip,deflate", @"Accept-Encoding", nil];
    NSMutableDictionary *getParams = [self fetchAPIEnvironment];
    if (url.count > 0) {
        [getParams addEntriesFromDictionary:url];
    }
    request.getParams = getParams;
    
    [MIURLConnection sendAsynchronousRequest:request queue:self completionHandler:finishHandler errorHandler:errorHandler];
}

@end
