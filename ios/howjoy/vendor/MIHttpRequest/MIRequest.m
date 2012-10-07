//
//  MIRequest.m
//  requester
//
//  Created by Wu Chang on 12-2-27.
//  Copyright (c) 2012年 Milan. All rights reserved.
//

#import "MIRequest.h"

@implementation MIRequest
@synthesize type, index, receivedData, host, getParams, postStrings, postDatas, postBody;

- (id)initWithURLString:(NSString *)URL
{
    //NSURL *theURL = [[NSURL alloc] initWithString: [NSString stringWithFormat:@"http://www.domain.com%@", URL]];
    NSURL *theURL = [[NSURL alloc] initWithString: URL];
    
    self = [super initWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    if (self) {
        self.type = 0;
        self.postBody = [[NSMutableData alloc] init];
        self.HTTPShouldHandleCookies = NO;
        self.HTTPMethod = @"POST";
        self.timeoutInterval = 30.0;
        self.allHTTPHeaderFields = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"MIHttpRequest/0.1 (iOS)", @"User-Agent",
                                    //@"application/json", @"Content-Type",
                                    nil];
    }
    return self;
}


- (void) setGetParams:(NSMutableDictionary *)params {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *key in params) {
        id object = [params objectForKey:key];
        NSString *value = [self objectToString:object];
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, [self urlEncode:value]]];
    }
    NSString *url = [NSString stringWithFormat:@"%@?%@", [self.URL absoluteString],[array componentsJoinedByString:@"&"]];
    self.URL = [[NSURL alloc] initWithString: url];
}

- (void) setPostStrings:(NSMutableDictionary *) pStrings {
    postStrings = pStrings;
    if (self.type == 0) {
        [self buildPostBody];
    }else if (self.type == 1) {
        self.postBody = [NSMutableData dataWithData: [[pStrings JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    self.HTTPBody = self.postBody;
}

- (void) setPostDatas:(NSMutableDictionary *) pDatas {
    postDatas = pDatas;
    [self buildMultipartFormDataPostBody];
    self.HTTPBody = self.postBody;
}

- (void) buildPostBody {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *key in postStrings) {
        id object = [postStrings objectForKey:key];
        NSString *value = [self objectToString:object];
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    NSString *body = [array componentsJoinedByString:@"&"];
    self.postBody = [NSMutableData dataWithData: [body dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)buildMultipartFormDataPostBody
{
    self.postBody = [NSMutableData data];
    
	NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	
	// We don't bother to check if post data contains the boundary, since it's pretty unlikely that it does.
	CFUUIDRef uuid = CFUUIDCreate(nil);
	NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuid);
	CFRelease(uuid);
	NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    uuidString = nil;
	
	[self addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary]];
    
	[self appendPostStrings:[NSString stringWithFormat:@"--%@\r\n",stringBoundary]];
	
	// Adds post data
    
	NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
	NSUInteger i=0;
	for (NSDictionary *key in postStrings) {
		[self appendPostStrings:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key]];
		[self appendPostStrings:[postStrings objectForKey:key]];
		i++;
		if (postStrings.count > 0 || i != postStrings.count) { //Only add the boundary if this is not the last item in the post body
			[self appendPostStrings:endItemBoundary];
		}
	}
    
	// Adds files to upload
	i=0;
	for (NSDictionary *key in postDatas) {
        NSDictionary *val = [postDatas objectForKey:key];
		[self appendPostStrings:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, [val objectForKey:@"fileName"]]];
		[self appendPostStrings:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [val objectForKey:@"contentType"]]];
		
		id data = [val objectForKey:@"data"];
		if ([data isKindOfClass:[NSURL class]]) {
			[self appendPostDataFromURL:data];
		} else if ([data isKindOfClass:[NSString class]]) {
			[self appendPostDataFromFile:data];
        } else {
            [self appendPostData:data];
        }
		i++;
		// Only add the boundary if this is not the last item in the post body
		if (i != postDatas.count) { 
			[self appendPostStrings:endItemBoundary];
		}
	}
	
	[self appendPostStrings:[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary]];
}


- (void)addRequestCookies:(NSDictionary *) cookies {
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:self.allHTTPHeaderFields];
    NSString *cookieInHeader = [headers objectForKey:@"Cookie"];
    NSMutableString *currentCookie;
    if (cookieInHeader) {
        currentCookie = [NSMutableString stringWithString: cookieInHeader];
    }else {
        currentCookie = [NSMutableString stringWithString: @"MIClient=iOS"];
    }
    for (NSString *key in cookies) {
        NSString *value = [cookies objectForKey:key];
        [currentCookie appendFormat: @"; %@=%@", key, value];
    }
	[headers setObject:currentCookie forKey:@"Cookie"];
    self.allHTTPHeaderFields = headers;
}

- (void)addRequestHeader:(NSString *)key value:(NSString *)value
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:self.allHTTPHeaderFields];
	[headers setObject:value forKey:key];
    self.allHTTPHeaderFields = headers;
}

- (void)appendPostStrings:(NSString *)string
{
	[self appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendPostData:(NSData *)data
{
	if ([data length] == 0) {
		return;
	}
    [self.postBody appendData:data];
}

- (void)appendPostDataFromFile:(NSString *)file
{
	NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:file];
	[stream open];
	NSUInteger bytesRead;
	while ([stream hasBytesAvailable]) {
		
		unsigned char buffer[1024*256];
		bytesRead = [stream read:buffer maxLength:sizeof(buffer)];
		if (bytesRead == 0) {
			break;
		}
        [self.postBody appendData:[NSData dataWithBytes:buffer length:bytesRead]];
	}
	[stream close];
}


- (void)appendPostDataFromURL:(NSURL *)url
{
    NSInputStream *stream = [[NSInputStream alloc] initWithURL:url];
    [stream open];
    NSUInteger bytesRead;
    while ([stream hasBytesAvailable]) {
        
        unsigned char buffer[1024*256];
        bytesRead = [stream read:buffer maxLength:sizeof(buffer)];
        if (bytesRead == 0) {
            break;
        }
        [self.postBody appendData:[NSData dataWithBytes:buffer length:bytesRead]];
    }
    [stream close];
}

- (NSString *) objectToString:(id) object{
    NSString *result;
    if ([object isKindOfClass:[NSString class]] == YES) {
        result = (NSString *)object;
    }else if ([object isKindOfClass:[NSDictionary class]] == YES) {
        result = [(NSDictionary *)object JSONRepresentation];
    }else if ([object isKindOfClass:[NSArray class]] == YES) {
        result = [(NSArray *)object JSONRepresentation];
    }else if ([object isKindOfClass:[NSNumber class]] == YES) {
        result = [(NSNumber *)object stringValue];
    }else if ([object isKindOfClass:[NSData class]] == YES) {
        result = [[NSString alloc] initWithData:(NSData *)object encoding:NSUTF8StringEncoding];
    }else {
        result = @"unknown object";
    }
    return result;
}

- (id) jsonToObject:(NSData *) jsonData{
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return [string JSONValue];
}

- (NSString *) urlEncode: (NSString *) string {
    NSString *escapedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                           NULL,
                                                                                           (__bridge CFStringRef)string,
                                                                                           NULL,
                                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                           kCFStringEncodingUTF8);
    
    return escapedString;
}

@end
