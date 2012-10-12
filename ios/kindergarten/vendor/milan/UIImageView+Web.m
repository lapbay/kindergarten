//
//  UIImageView+Web.m
//  gdst
//
//  Created by com milan on 7/3/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import "UIImageView+Web.h"

@implementation UIImageView (Web)

- (id)initWithURL:(NSString *)URL withIndex:(NSString *)index{
    self = [self initWithImage:[UIImage imageNamed:@"nothing"]];
    if (self) {
        [self loadWebImage:URL withIndex:index];
    }
    return self;
}

- (void)loadWebImage:(NSString *)URL withIndex:(NSString *)index{
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager fileCacher:URL withFinishHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             UIImage *theImage = [UIImage imageWithData:data];
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.contentMode = UIViewContentModeScaleAspectFill;
                 self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.width * theImage.size.height / theImage.size.width);
                 if (self.superview && [self.superview isKindOfClass:[UIScrollView class]]) {
                     ((UIScrollView *)self.superview).contentSize =CGSizeMake(self.frame.size.width, self.frame.size.height);
                     
                     ((UIScrollView *)self.superview).maximumZoomScale = MAX(theImage.size.width/self.frame.size.width, theImage.size.height/self.frame.size.height);
                 }
                 self.image = theImage;
             });
         }
     } withDownloadHandler:^(NSURLConnection *connection, NSInteger totalBytesReceived, NSInteger totalBytesExpectedToReceive)
     {
         //         NSLog(@"load web image progress: %i, %i", totalBytesReceived, totalBytesExpectedToReceive);
         //         dispatch_async(dispatch_get_main_queue(), ^{
         //         });
     }];
}

- (void)loadWebImages:(NSArray *)URLs withIndex:(NSString *)index{
    self.animationDuration = 3;
    MIRequestManager *manager = [MIRequestManager requestManager];
    //    NSInteger i = 0;
    for (NSString *URL in URLs) {
        [manager fileLoader:URL withFinishHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if ([data length] > 0 && error == nil){
                 UIImage *theImage = [UIImage imageWithData:data];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSMutableArray *images;
                     if (self.animationImages) {
                         images= [NSMutableArray arrayWithArray:self.animationImages];
                         [images addObject:theImage];
                     }else {
                         images = [NSArray arrayWithObject:theImage];
                     }
                     self.image = nil;
                     self.animationImages = images;
                     [self startAnimating];
                 });
             }
         } withDownloadHandler:^(NSURLConnection *connection, NSInteger totalBytesReceived, NSInteger totalBytesExpectedToReceive)
         {
             //             NSLog(@"load web image progress: %i, %i", totalBytesReceived, totalBytesExpectedToReceive);
             //             dispatch_async(dispatch_get_main_queue(), ^{
             //             });
         }];
    }
}

- (void)imageDidFinishLoading:(NSDictionary *)response{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        NSString *index = [response objectForKey:@"NSIndex"];
        NSData *data = [NSData dataWithData: [response objectForKey:@"data"]];
        UIImage *theImage = [UIImage imageWithData:data];
        if (self.animationDuration == 3) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *images;
                if (self.animationImages) {
                    images= [NSMutableArray arrayWithArray:self.animationImages];
                    [images addObject:theImage];
                }else {
                    images = [NSArray arrayWithObject:theImage];
                }
                self.image = nil;
                self.animationImages = images;
                [self startAnimating];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = theImage;
            });
        }
	});
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error");
}

@end
