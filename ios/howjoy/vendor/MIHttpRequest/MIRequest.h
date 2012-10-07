//
//  MIRequest.h
//  requester
//
//  Created by Wu Chang on 12-2-27.
//  Copyright (c) 2012年 Milan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"


@interface MIRequest : NSMutableURLRequest

@property (assign, nonatomic) NSInteger type;
@property (strong, nonatomic) NSNumber *index;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSMutableData *postBody;
@property (strong, nonatomic) NSMutableDictionary *getParams;
@property (strong, nonatomic) NSMutableDictionary *postStrings;
@property (strong, nonatomic) NSMutableDictionary *postDatas;

- (id)initWithURLString:(NSString *)URL;

- (void) buildPostBody;
- (void) buildMultipartFormDataPostBody;
- (void) addRequestHeader:(NSString *)header value:(NSString *)value;
- (void) addRequestCookies:(NSDictionary *) cookies;

- (NSString *) objectToString:(id) object;
- (NSString *) urlEncode: (NSString *) string;

@end
