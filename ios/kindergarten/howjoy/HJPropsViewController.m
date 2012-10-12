//
//  HJPropsViewController.m
//  howjoy
//
//  Created by Wu Chang on 9/12/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJPropsViewController.h"
#import "IIViewDeckController.h"

#import "MIRequestManager+API.h"
#import <MapKit/MapKit.h>
#import "DemoTransition.h"
#import "MBProgressHUD.h"

@interface HJPropsViewController ()

@end

@implementation HJPropsViewController
@synthesize contentView = _contentView;
@synthesize animationViewContainer = _animationViewContainer;
@synthesize animationView = _animationView;
@synthesize animationView1 = _animationView1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"寻宝", @"Find Props");
        NSURL *filePath   = [[NSBundle mainBundle] URLForResource:   @"Hero" withExtension: @"aiff"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
        self.recordData = [NSMutableDictionary dictionary];
        self.currentProductIndex = 0;
        self.productsArray = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView1:)];
    [self.animationView addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView2:)];
    [self.animationView1 addGestureRecognizer:tap2];

    [self setGeo];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", @"Back")
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(shouldDismiss:)];
    self.navigationItem.leftBarButtonItem = leftButton;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    //    [self showCam:nil];
    [self getShopInfo];
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)getShopInfo {
    if ([SKPaymentQueue canMakePayments]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        NSSet *set = [NSSet setWithArray:[[NSArray alloc] initWithObjects:@"com.howjoy.howjoysandbox.lottery", @"com.howjoy.howjoy.lotteryegg3", nil]];
        
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
        [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"应用内购买已被禁用, 请启用后再重试"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [alert show];
    }
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
//    NSLog(@"products: %@", response.products);
//    NSLog(@"invalidProductIdentifiers: %@", response.invalidProductIdentifiers);

    self.productsArray = response.products;
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];

    for (SKProduct *product in response.products) {
        NSLog(@"商品标题:%@",product.localizedTitle);
        NSLog(@"商品价格:%@",product.price);
        NSLog(@"商品描述:%@",product.localizedDescription);
    }
    
}
- (void)buyProduct:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct: product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchasing://购买中
                NSLog(@"购买中");
                break;
                
            case SKPaymentTransactionStatePurchased://购买成功
                [self fallDownAnimationViewWithIndex:1];
                [queue finishTransaction:transaction];
                NSLog(@"购买成功");
                break;
                
            case SKPaymentTransactionStateFailed://购买失败
                [queue finishTransaction:transaction];
                NSLog(@"购买失败");
                break;
                
            case SKPaymentTransactionStateRestored://恢复商品
                NSLog(@"恢复商品");
                break;
                
            default:
                break;
        }
    }
}

//- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
//    NSLog(@"-------弹出错误信息----------");
//    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",NULL) message:[error localizedDescription]
//                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
//    [alerView show];
//}
//-(void) requestDidFinish:(SKRequest *)request
//{
//    NSLog(@"----------反馈信息结束--------------");
//    
//}
//-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
//    NSLog(@"-----PurchasedTransaction----");
//    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
//    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
//}
//- (void) completeTransaction: (SKPaymentTransaction *)transaction
//
//{
//    NSLog(@"-----completeTransaction--------");
//    // Your application should implement these two methods.
//    NSString *product = transaction.payment.productIdentifier;
//    if ([product length] > 0) {
//        
//        NSArray *tt = [product componentsSeparatedByString:@"."];
//        NSString *productId = [tt lastObject];
//        if ([productId length] > 0) {
//            [self recordTransaction:productId];
//            [self provideContent:productId];
//        }
//    }
//    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
//    
//}
//
////记录交易
//-(void)recordTransaction:(NSString *)product{
//    NSLog(@"-----记录交易--------");
//}
////处理下载内容
//-(void)provideContent:(NSString *)product{
//    NSLog(@"-----下载--------");
//}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [cellData objectForKey:@"name"];
    
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
}

- (void)setGeo {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1000.0f;
    [locationManager startUpdatingLocation];
    CLLocationCoordinate2D coordinate = [[locationManager location] coordinate];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%f", coordinate.longitude], @"longitude", [NSString stringWithFormat:@"%f", coordinate.latitude], @"latitude", nil];
    [self.recordData addEntriesFromDictionary:params];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) {
        [self fallDownAnimationViewWithIndex:0];
    }
    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}
- (void)tapOnView1:(id) sender {
    self.currentProductIndex = 0;
    [self fallDownAnimationViewWithIndex:0];
}
- (void)tapOnView2:(id) sender {
    self.currentProductIndex = 1;
    if (self.productsArray.count > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"确认要购买更大的中奖几率吗?"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [alert show];
    }else{
        
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        Log(@"%@", self.productsArray);
        if (self.productsArray.count > 0) {
            SKProduct *product = [self.productsArray objectAtIndex:self.currentProductIndex];
            [self buyProduct: product];
        }
    }
}

- (void) fallDownAnimationViewWithIndex:(NSInteger) index{
    NSObject<EPGLTransitionViewDelegate> *transition;
    UIImageView *animateView;
    switch (index) {
        case 0:
        {
            animateView = self.animationView;
            break;
        }
        case 1:
        {
            animateView = self.animationView1;
            break;
        }
        default:
            break;
    }
    [self queryPropsList:nil];

    transition = [[DemoTransition alloc] init];
    
    EPGLTransitionView *glview = [[EPGLTransitionView alloc] initWithView:animateView delegate:transition];
    glview.frame = CGRectMake(glview.frame.origin.x, 128 + 64, glview.frame.size.width, glview.frame.size.height);
    [glview prepareTextureTo:animateView];
    glview.backgroundColor = [UIColor clearColor];
    
    [glview startTransition];
    AudioServicesPlaySystemSound(soundID);

    [self.view sendSubviewToBack:self.animationViewContainer];
}

- (void)queryPropsList:(id) sender {
    [self.recordData setObject:[NSString stringWithFormat:@"%i", self.currentProductIndex] forKey:@"index"];
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiFindProps:self.recordData withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
                     NSArray *d = [resp objectForKey:@"d"];
                     self.dataSource = [NSMutableArray arrayWithArray:d];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.contentView reloadData];
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
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
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
         });
     }];
}



@end
