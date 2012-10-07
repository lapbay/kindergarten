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

@interface HJPropsViewController ()

@end

@implementation HJPropsViewController
@synthesize contentView = _contentView;
@synthesize animationView = _animationView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"寻宝", @"Find Props");
        NSURL *filePath   = [[NSBundle mainBundle] URLForResource:   @"Hero" withExtension: @"aiff"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
        self.recordData = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [self queryPropsList:nil];
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

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
    if ( event.subtype == UIEventSubtypeMotionShake ) {
        [self fallDownAnimationView];
    }
    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}

- (void) fallDownAnimationView {
    NSObject<EPGLTransitionViewDelegate> *transition;
    
    transition = [[DemoTransition alloc] init];
    
    EPGLTransitionView *glview = [[EPGLTransitionView alloc] initWithView:self.animationView delegate:transition];
    glview.frame = CGRectMake(glview.frame.origin.x, glview.frame.origin.x + 64, glview.frame.size.width, glview.frame.size.height);
    [glview prepareTextureTo:self.animationView];
    glview.backgroundColor = [UIColor clearColor];
    
    [glview startTransition];
    AudioServicesPlaySystemSound(soundID);

    [self.view sendSubviewToBack:self.animationView];
}

- (void)queryPropsList:(id) sender {
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
