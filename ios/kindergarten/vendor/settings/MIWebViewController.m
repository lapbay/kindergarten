//
//  MIWebViewController.m
//  gdst
//
//  Created by com milan on 12-6-2.
//  Copyright (c) 2012年 unique. All rights reserved.
//

#import "MIWebViewController.h"

@interface MIWebViewController ()

@end

@implementation MIWebViewController
@synthesize webView1, hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"信息", @"Infomations");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.webView1.delegate = self;
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:self.hud];
    self.hud.labelText = @"...";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadWebPageWithURLString:(NSString*)url {

    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView1 loadRequest:request];
//    [self.hud show:YES];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
//    [self.hud hide:YES];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
