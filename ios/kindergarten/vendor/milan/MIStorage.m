//
//  MIStorage
//  milan
//
//  Created by Wu Chang on 11-9-20.
//  Copyright 2011年 Unique. All rights reserved.
//

#import "MIStorage.h"

@implementation MIStorage
@synthesize storage;

static MIStorage *sharedGizmoManager = nil;

+ (MIStorage *)sharedManager
{
    if (sharedGizmoManager == nil) {
        sharedGizmoManager = [[super allocWithZone:NULL] init];
        
        NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        destPath = [destPath stringByAppendingPathComponent:@"storage.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:destPath]) {
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"plist"];
            if (sourcePath) {
                [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];                
            }

        }
        
        sharedGizmoManager.storage = [[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    }
    return sharedGizmoManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSMutableDictionary *) read {
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"storage.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    sharedGizmoManager.storage = [[NSMutableDictionary alloc] initWithContentsOfFile:destPath];
    return sharedGizmoManager.storage;
}

- (void) save {
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"storage.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    [sharedGizmoManager.storage writeToFile:destPath atomically:YES];
}

-(void)hello
{
    NSLog(@"Hello World");
}

-(void) initialData {
}

#pragma mark - User
- (BOOL) isLogin {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isLoggedIn = [[userDefaults objectForKey:@"login"] boolValue];
    return isLoggedIn;
}

- (NSString * ) currentUserId {
    NSString * userName = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[[userDefaults objectForKey:@"user"] objectForKey:@"profile"]);
    userName = [[[userDefaults objectForKey:@"user"] objectForKey:@"profile"] objectForKey:@"_id"];
    return userName;
}
- (NSString * ) currentUserName {
    NSString * userName = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userName = [[[userDefaults objectForKey:@"user"] objectForKey:@"profile"] objectForKey:@"name"];
    return userName;
}
- (NSDictionary * ) currentUserProfileDictionary {
    NSDictionary * profileDict = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    profileDict = [[userDefaults objectForKey:@"user"] objectForKey:@"profile"];
    return profileDict;
}
- (NSString *) currentUserRank{
    NSNumber * userRank = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userRank = [[[userDefaults objectForKey:@"user"] objectForKey:@"profile"] objectForKey:@"rank"];
    return [NSString stringWithFormat:@"%@",userRank];
}
- (NSString *) currentUserLevel{
    NSNumber * userLevel = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userLevel = [[[userDefaults objectForKey:@"user"] objectForKey:@"profile"] objectForKey:@"level"];
    return [NSString stringWithFormat:@"%@",userLevel];
}
- (NSString *) currentUserIntroducation{
    NSString * userIntroduction = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userIntroduction = [[[userDefaults objectForKey:@"user"] objectForKey:@"profile"] objectForKey:@"introduction"];
    return userIntroduction;
}
@end