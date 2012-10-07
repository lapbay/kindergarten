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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"优惠码"
                                                    message:symbol.data
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self shouldDismiss:nil];
}

@end
