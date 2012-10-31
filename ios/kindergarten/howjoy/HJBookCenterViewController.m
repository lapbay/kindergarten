//
//  HJBookCenterViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HJBookCenterViewController.h"
#import "MIRequestManager+API.h"
#import "HJBookCenterCell.h"
#import "HJFeedViewController.h"
#import "HJProfileViewController.h"
#import "HJTaskViewController.h"
#import "HJNotificationCenterViewController.h"
#import "HJTaskSeriesViewController.h"
#import "MIWebViewController.h"

@interface HJBookCenterViewController ()

@end

@implementation HJBookCenterViewController
@synthesize contentView = _contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"图书中心", @"Books");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.dataSource = [NSMutableArray array];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Notification", @"Notification")
//                                                                  style:UIBarButtonItemStyleBordered
//                                                                 target:self
//                                                                 action:@selector(notificationButtonTapped:)];
//    self.navigationItem.rightBarButtonItem = NavButton;

    self.contentView.delegate = self;
    self.contentView.dataSource = self;
    
    [self initRefreshView:self.contentView];
    isLoading = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshFooterTriggered];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];

    static NSString *CellIdentifier = @"HJBookCenterCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
    HJBookCenterCell *cell = (HJBookCenterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HJBookCenterCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects) {
            if([currentObject isKindOfClass:[HJBookCenterCell class]]) {
                cell = (HJBookCenterCell *) currentObject;
                break;
            }
        }
    }
    
    switch ([[cellData objectForKey:@"type"] intValue]) {
        case 0:
        {
            cell.contentView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
            break;
        }
        case 1:
        {
            cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
            break;
        }
        case 2:
        {
            cell.contentView.backgroundColor = [UIColor underPageBackgroundColor];
            break;
        }
        default:
            break;
    }
    
    cell.titleLabel.text = [cellData objectForKey:@"title"];
    cell.placeLabel.text = [cellData objectForKey:@"desc"];

    cell.textLabel.backgroundColor = [UIColor clearColor];
	[self configureCell:cell atIndexPath:indexPath];
    [self relocateFooter];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
    Log(@"%@", cellData);
    MIWebViewController *web = [[MIWebViewController alloc] initWithNibName:@"MIWebViewController" bundle:nil];
    web.title = @"Google";
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    [web loadWebPageWithURLString: [cellData objectForKey:@"url"]];
}


- (IBAction)notificationButtonTapped: (id) sender {
    HJNotificationCenterViewController *notification = [[HJNotificationCenterViewController alloc] initWithNibName:@"HJNotificationCenterViewController" bundle:nil];
    UINavigationController *notiController = [[UINavigationController alloc] initWithRootViewController:notification];

    [self presentModalViewController:notiController animated:YES];
}

- (void) refreshHeaderTriggered {
    [self performSelector:@selector(stopHeaderAction) withObject:nil afterDelay:1.0];
}

- (void)refreshFooterTriggered {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", self.pageDown], @"page", nil];

    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiBookCenter:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self performSelectorOnMainThread:@selector(stopAction) withObject:nil waitUntilDone:[NSThread isMainThread]];
         });
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 NSArray *d = [resp objectForKey:@"d"];
                 [self.dataSource addObjectsFromArray:d];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.contentView reloadData];
                 });
                 
                 @try {
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
             [self performSelectorOnMainThread:@selector(stopAction) withObject:nil waitUntilDone:[NSThread isMainThread]];
         });
     }];
}

@end
