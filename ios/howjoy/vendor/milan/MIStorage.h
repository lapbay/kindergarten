//
//  MIStorage
//  milan
//
//  Created by Wu Chang on 11-9-20.
//  Copyright 2011年 Unique. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MIStorage : NSObject {
    NSArray* viewControllers;
    NSDictionary *dict;
}

+ (MIStorage *) sharedManager;
+ (id)allocWithZone: (NSZone *)zone;
- (id)copyWithZone: (NSZone *)zone;

@property (retain, nonatomic) NSMutableDictionary *storage;

- (NSMutableDictionary *) read;
-(void) save;

-(void)hello;
-(void) initialData;

#pragma mark - User

- (BOOL) isLogin;

- (NSString * ) currentUserId;
- (NSString * ) currentUserName;
- (NSDictionary * ) currentUserProfileDictionary;

- (NSString *) currentUserRank;
- (NSString *) currentUserLevel;
- (NSString *) currentUserIntroducation;
@end