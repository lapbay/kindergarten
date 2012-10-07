//
//  UIImageView+Web.h
//  gdst
//
//  Created by com milan on 7/3/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIRequestManager+API.h"

@interface UIImageView (Web) <MIRequestDelegate>

- (id)initWithURL:(NSString *)URL withIndex:(NSString *)index;
- (void)loadWebImage:(NSString *)URL withIndex:(NSString *)index;
- (void)loadWebImages:(NSArray *)URLs withIndex:(NSString *)index;
- (void)imageDidFinishLoading:(NSDictionary *)response;

@end
