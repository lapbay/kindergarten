//
//  MILoginViewController.m
//  gdst
//
//  Created by com milan on 12-5-23.
//  Copyright (c) 2012年 unique. All rights reserved.
//

#import "MILoginViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface MILoginViewController ()

@end

@implementation MILoginViewController
@synthesize submitButton, hud, userField, pswdField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self.submitButton addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.userField.delegate = self;
    self.pswdField.delegate = self;
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:self.hud];
//    self.hud.delegate = self;
    self.hud.labelText = @"正在查询...";
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.userField resignFirstResponder];
    [self.pswdField resignFirstResponder];
}

- (IBAction) loginButtonTapped: (id) sender {
    [self doAction:[NSNumber numberWithInt:0]];
}

- (void) doAction: (NSNumber *) index{
    [self.pswdField resignFirstResponder];
    Reachability *r = [Reachability reachabilityWithHostname:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"没有可用网络"
                                                            message:@"请开启网络连接"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return;
            break;
        }
        case ReachableViaWWAN:
            break;
        case ReachableViaWiFi:
            break;
    }
    
    NSMutableDictionary *inputs = [[NSMutableDictionary alloc] init];
    if (self.userField.text) {
        [inputs setObject:self.userField.text forKey:@"email"];
    }
    if (self.pswdField.text) {
//        NSString *md5pwd = [MIRequestManager md5HexDigest:self.pswdField.text];
        [inputs setObject:self.pswdField.text forKey:@"password"];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults objectForKey:@"push_token"];
    if (token) {
        [inputs setValue:token forKey:@"ios_token"];
    }
    [self.hud show:YES];
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiUserLogin:inputs withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.hud hide:YES];
         });

         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
                     NSDictionary *d = [resp objectForKey:@"d"];
                     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                     [userDefaults setBool:YES forKey:@"login"];
                     [userDefaults setValue:[d objectForKey:@"token"] forKey:@"token"];
                     [userDefaults setValue:d forKey:@"user"];
                     NSLog(@"%@",d);
                     NSString *cookie = [[(NSHTTPURLResponse *) response allHeaderFields] objectForKey:@"Set-Cookie"];
                     if (cookie) {
                         NSDictionary *cookie_pair = [NSDictionary dictionaryWithObject:cookie forKey:MIAPIHost];
                         [userDefaults setValue:cookie_pair forKey:@"cookies"];
                     }
                     [userDefaults synchronize];

                     dispatch_async(dispatch_get_main_queue(), ^{
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"MILoginDidFinishedSuccessfully" object:nil];
                         
                         [self.userField resignFirstResponder];
                         [self.pswdField resignFirstResponder];
                         [UIView animateWithDuration:0.6 animations:^(void){
                             self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                         } completion:^(BOOL finished){
                             if (finished) {
                                 [self.view removeFromSuperview];
                             }
                         }];

                     });
                 }
                 @catch (NSException *exception) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                     message:@"服务器返回数据错误"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [alert show];
                     });
                 }
                 @finally {
                     
                 }
             }else {
                 NSString *msg;
                 if ([resp objectForKey:@"d"]) {
                     if ([[resp objectForKey:@"d"] isKindOfClass:[NSString class]]) {
                         msg = [resp objectForKey:@"d"];
                     }else if ([[resp objectForKey:@"d"] isKindOfClass:[NSDictionary class]]) {
                         msg = [[resp objectForKey:@"d"] objectForKey:@"message"];
                     }
                 }else if ([resp objectForKey:@"error"]) {
                     msg = [resp objectForKey:@"error"];
                 }else if ([resp objectForKey:@"message"]) {
                     msg = [resp objectForKey:@"message"];
                 }else{
                     msg = @"服务器未返回可读的错误信息";
                 }
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                 message:msg
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil, nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [alert show];
                 });
             }
         }
     } withErrorHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.hud hide:YES];
         });
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *) tf {
    if (tf.returnKeyType == UIReturnKeyNext) {
        if (![self.pswdField isFirstResponder]) {
            [self.pswdField becomeFirstResponder];
        }
    }else {
        [self doAction:[NSNumber numberWithInt:1]];
    }
    return YES;
}

@end
