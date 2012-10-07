//
//  MIRequestManager+API.h
//  requester
//
//  Created by Wu Chang on 12-3-1.
//  Copyright (c) 2012年 Milan. All rights reserved.
//

#import "MIRequestManager.h"
#import "SBJson.h"

@interface MIRequestManager (sampleAPI)

- (void) apiSampleDelegate:(NSString *) url withIndex: (NSString *)index withDelegate: (NSObject <MIRequestDelegate> *) delegate;
- (void) apiSampleBlock:(NSString *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;

@end

@interface MIRequestManager (appAPI)
- (void) apiUserLogin:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiUserLogout:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;

- (void) apiProfile:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiFriendsList:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiFriendRequest:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiFriendResponse:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiFriendRemove:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiInviteFriends:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;

- (void) apiSearches:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiNotificationCenter:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;

- (void) apiFeedCenter:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiFeedInfo:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;

- (void) apiUserTasks:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiTaskCenter:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiTaskCreate:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiTaskInfo:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiTaskUpdate:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;

- (void) apiJoinTask:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiDoingTask:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiFinishTask:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiRecordTask:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;

- (void) apiFindProps:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;
- (void) apiUserProps:(NSDictionary *) url withFinishHandler:(void (^)(NSURLResponse*, NSData*, NSError*))finishHandler withErrorHandler:(void (^)(NSURLResponse*, NSData*, NSError*))errorHandler;

@end