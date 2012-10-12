//
//  PGScanSubViewController.m
//  gdst
//
//  Created by com milan on 12-5-22.
//  Copyright (c) 2012年 unique. All rights reserved.
//

#import "HJScanViewController.h"
#import "IIViewDeckController.h"

@interface HJScanViewController ()

@end

@implementation HJScanViewController
@synthesize resultImage, resultText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.tabBarItem.image = [UIImage imageNamed:@"scan"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"扫描", @"Scan");
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", @"Back")
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(shouldDismiss:)];
    self.navigationItem.leftBarButtonItem = leftButton;

    self.showsZBarControls = NO;
    self.readerDelegate = self;
    self.supportedOrientationsMask = ZBarOrientationMaskAll;
    [self.scanner setSymbology: ZBAR_I25
                        config: ZBAR_CFG_ENABLE
                            to: 0];
    CGRect f = self.readerView.frame;
    self.readerView.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, f.size.height + 60);
}

- (IBAction)shouldDismiss:(id)sender {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self dismissModalViewControllerAnimated:YES];
    self.viewDeckController.shouldFireViewMethods = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) scanButtonTapped
{
    NSLog(@"TBD: scan barcode here...");
    [self settleScanButton];
}

- (void) settleScanButton {
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scaner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scaner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self.navigationController pushViewController:reader animated:YES];
//    [self presentModalViewController: reader animated: NO];
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    resultText.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
    resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    //[reader dismissModalViewControllerAnimated: YES];
    
    NSLog(@"%@", symbol.data);
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:self.hud];
    self.hud.labelText = @"扫描结果是:";
    self.hud.detailsLabelText = [NSString stringWithFormat:@"%@ \r\n\r\n正在解码...", symbol.data];
    [self.hud show:YES];
    [self unlockCoupons:symbol.data];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self shouldDismiss:nil];
}

- (void)unlockCoupons:(NSString *) txt {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: txt, @"txt", nil];
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiUnlockCoupons:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
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
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"优惠码"
                                                                     message:[d objectForKey:@"coupon"]
                                                                    delegate:self
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil, nil];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [alert show];
                     });

                 }
                 @catch (NSException *exception) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                     message:@"服务器返回数据错误"
                                                                    delegate:self
                                                           cancelButtonTitle:@"确定"
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
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                 message:msg
                                                                delegate:self
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil, nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [alert show];
                 });
             }
         }
     } withErrorHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
         });
     }];
}

@end
