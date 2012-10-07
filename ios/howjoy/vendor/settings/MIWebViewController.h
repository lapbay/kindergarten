//
//  MIWebViewController.h
//  gdst
//
//  Created by com milan on 12-6-2.
//  Copyright (c) 2012年 unique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MIWebViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *webView1;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView1;
@property (retain, nonatomic) MBProgressHUD *hud;

- (void)loadWebPageWithURLString:(NSString*)url;

@end
