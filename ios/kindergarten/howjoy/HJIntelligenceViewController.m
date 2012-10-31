//
//  HJIntelligenceViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HJIntelligenceViewController.h"
#import "MIRequestManager+API.h"
#import "HJFeedCellDefault.h"
#import "HJFeedViewController.h"
#import "HJProfileViewController.h"
#import "HJTaskViewController.h"
#import "HJNotificationCenterViewController.h"
#import "HJTaskSeriesViewController.h"
#import "SVSegmentedControl.h"

#import "UIImageView+Web.h"
#import "HJChatViewController.h"
#import "HJProfilePickerViewController.h"
#import "MBProgressHUD.h"

@interface HJIntelligenceViewController ()

@end

@implementation HJIntelligenceViewController
@synthesize contentView = _contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil type:(HJIntelligenceViewType)typ
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.type = typ;
        self.title = NSLocalizedString(@"信息", @"Messages");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"信息", @"Messages");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.dataSource = [NSMutableArray array];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    SVSegmentedControl *grayRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"消息", @"通知", @"私信", nil]];
    [grayRC addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	grayRC.font = [UIFont boldSystemFontOfSize:13];
	grayRC.titleEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 24);
	grayRC.height = 32;
	grayRC.thumb.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.1 alpha:1];
	[self.view addSubview:grayRC];
	grayRC.center = CGPointMake(160, 20);
    
    switch (self.type) {
        case HJIntelligenceViewTypeFeeds:
        {
            break;
        }
        case HJIntelligenceViewTypeNotifications:
        {
            break;
        }
        case HJIntelligenceViewTypeMessages:
        {
            UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(createButtonTapped:)];
            self.navigationItem.rightBarButtonItem = NavButton;
            break;
        }
        default:
        {
            break;
        }
    }

    self.contentView.delegate = self;
    self.contentView.dataSource = self;
    
    [self initRefreshView:self.contentView];
    isLoading = YES;
//    [self refreshFooterTriggered];

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 44.0f;
    switch (self.type) {
        case HJIntelligenceViewTypeFeeds:
        {
            height = 80.0f;
            break;
        }
        case HJIntelligenceViewTypeNotifications:
        {
            height = 44.0f;
            break;
        }
        case HJIntelligenceViewTypeMessages:
        {
            height = 64.0f;
            break;
        }
        default:
        {
            break;
        }
    }
    return MAX(height, 44.0f);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.type) {
        case HJIntelligenceViewTypeFeeds:
        {
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            
            static NSString *CellIdentifier = @"HJFeedCell";
            HJFeedCellDefault *cell = (HJFeedCellDefault *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HJFeedCellDefault" owner:nil options:nil];
                for(id currentObject in topLevelObjects) {
                    if([currentObject isKindOfClass:[HJFeedCellDefault class]]) {
                        cell = (HJFeedCellDefault *) currentObject;
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
            cell.placeLabel.text = [cellData objectForKey:@"content"];
            
            cell.textLabel.backgroundColor = [UIColor clearColor];
            [self configureCell:cell atIndexPath:indexPath];
            [self relocateFooter];
            return cell;
            break;
        }
        case HJIntelligenceViewTypeNotifications:
        {
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.textLabel.textAlignment = UITextAlignmentLeft;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            }
            
            cell.textLabel.text = [cellData objectForKey:@"title"];
            
            return cell;
            break;
        }
        case HJIntelligenceViewTypeMessages:
        {
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            
            static NSString *CellIdentifier = @"HJMessageCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            //    HJFeedCellDefault *cell = (HJFeedCellDefault *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //    if (cell == nil) {
            //        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HJFeedCellDefault" owner:nil options:nil];
            //        for(id currentObject in topLevelObjects) {
            //            if([currentObject isKindOfClass:[HJFeedCellDefault class]]) {
            //                cell = (HJFeedCellDefault *) currentObject;
            //                break;
            //            }
            //        }
            //    }
            //
            //    cell.titleLabel.text = [cellData objectForKey:@"title"];
            //    cell.placeLabel.text = [cellData objectForKey:@"content"];
            
            cell.detailTextLabel.text = [cellData objectForKey:@"content"];
            
            NSString *my_id = [[MIStorage sharedManager] currentUserId];
            NSString *fid = [cellData objectForKey:@"from_id"];
            NSString *tid = [cellData objectForKey:@"to_id"];
            NSString *avatar;
            if ([my_id isEqualToString:fid]) {
                cell.textLabel.text = [[cellData objectForKey:@"to"] objectForKey:@"name"];
                avatar = [[cellData objectForKey:@"to"] objectForKey:@"avatar"];
            }else if ([my_id isEqualToString:tid]){
                cell.textLabel.text = [[cellData objectForKey:@"from"] objectForKey:@"name"];
                avatar = [[cellData objectForKey:@"from"] objectForKey:@"avatar"];
            }else{
                avatar = @"/default.jpg";
            }
            avatar = @"http://www.google.com/images/google_favicon_128.png";
            if (avatar.length > 0) {
                [cell.imageView setImage:[UIImage imageNamed:@"placeholder"]];
                //        [cell.imageView loadWebImage:avatar withIndex:@""];
            }else{
                [cell.imageView setImage:nil];
            }
            
            [self configureCell:cell atIndexPath:indexPath];
            //    [self relocateFooter];
            return cell;
            break;
        }
        default:
        {
            return nil;
            break;
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (self.type) {
        case HJIntelligenceViewTypeFeeds:
        {
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            switch ([[cellData objectForKey:@"type"] intValue]) {
                case 0:
                {
                    HJTaskViewController *task = [[HJTaskViewController alloc] initWithNibName:@"HJTaskViewController" bundle:nil];
                    task.taskId = [[cellData objectForKey:@"task"] objectForKey:@"id"];
                    [self.navigationController pushViewController:task animated:YES];
                    break;
                }
                case 1:
                {
                    HJTaskSeriesViewController *task = [[HJTaskSeriesViewController alloc] initWithNibName:@"HJTaskSeriesViewController" bundle:nil];
                    task.type = HJTaskTypeView;
                    task.taskId = [[cellData objectForKey:@"task"] objectForKey:@"id"];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:task];
                    [self presentModalViewController:navController animated:YES];
                    break;
                }
                case 2:
                {
                    HJProfileViewController *profile = [[HJProfileViewController alloc] initWithNibName:@"HJProfileViewController" bundle:nil];
                    profile.profileId = [[cellData objectForKey:@"people"] objectForKey:@"id"];
                    [self.navigationController pushViewController:profile animated:YES];
                    break;
                }
                case 3:
                {
                    HJFeedViewController *feed = [[HJFeedViewController alloc] initWithNibName:@"HJFeedViewController" bundle:nil];
                    [self.navigationController pushViewController:feed animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case HJIntelligenceViewTypeNotifications:
        {
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            switch ([[cellData objectForKey:@"type"] intValue]) {
                case 0:
                {
                    HJTaskViewController *task = [[HJTaskViewController alloc] initWithNibName:@"HJTaskViewController" bundle:nil];
                    task.taskId = [[cellData objectForKey:@"task"] objectForKey:@"id"];
                    [self.navigationController pushViewController:task animated:YES];
                    break;
                }
                case 1:
                {
                    HJTaskSeriesViewController *task = [[HJTaskSeriesViewController alloc] initWithNibName:@"HJTaskSeriesViewController" bundle:nil];
                    task.type = HJTaskTypeView;
                    task.taskId = [[cellData objectForKey:@"task"] objectForKey:@"id"];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:task];
                    [self presentModalViewController:navController animated:YES];
                    break;
                }
                case 2:
                {
                    HJProfileViewController *profile = [[HJProfileViewController alloc] initWithNibName:@"HJProfileViewController" bundle:nil];
                    profile.profileId = [[cellData objectForKey:@"people"] objectForKey:@"id"];
                    [self.navigationController pushViewController:profile animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case HJIntelligenceViewTypeMessages:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            NSString *my_id = [[MIStorage sharedManager] currentUserId];
            NSString *fid = [cellData objectForKey:@"from_id"];
            NSString *tid = [cellData objectForKey:@"to_id"];
            NSString *uid;
            NSString *uname;
            if ([my_id isEqualToString:fid]) {
                uid = tid;
                uname = [[cellData objectForKey:@"to"] objectForKey:@"name"];
            }else if ([my_id isEqualToString:tid]){
                uid = fid;
                uname = [[cellData objectForKey:@"from"] objectForKey:@"name"];
            }else{
            }
            if (uid) {
                HJChatViewController *viewController = [[HJChatViewController alloc] initWithNibName:@"HJChatViewController" bundle:nil];
                viewController.withId = uid;
                viewController.title = uname;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            break;
        }
        default:
        {
            break;
        }
    }
}


- (IBAction)segmentAction: (SVSegmentedControl *) sender {
    NSInteger showingSegment = sender.selectedIndex;
    self.selectedIndex = showingSegment;
    self.pageDown = 0;
    switch (showingSegment) {
        case 0:
        {
            self.type = HJIntelligenceViewTypeFeeds;
            if (!self.navigationItem.rightBarButtonItem) {
                UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(createButtonTapped:)];
                self.navigationItem.rightBarButtonItem = NavButton;
            }
            [self fetchFeeds];
            break;
        }
        case 1:
        {
            self.type = HJIntelligenceViewTypeNotifications;
            if (self.navigationItem.rightBarButtonItem) {
                self.navigationItem.rightBarButtonItem = nil;
            }
            [self fetchNotifications];
            break;
        }
        case 2:
        {
            self.type = HJIntelligenceViewTypeMessages;
            if (!self.navigationItem.rightBarButtonItem) {
                UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(createButtonTapped:)];
                self.navigationItem.rightBarButtonItem = NavButton;
            }
            [self fetchMessages];
            break;
        }
        default:
        {
            self.type = HJIntelligenceViewTypeFeeds;
            break;
        }
    }
    self.dataSource = [NSMutableArray array];
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
    NSInteger showingSegment = self.selectedIndex;
    switch (showingSegment) {
        case 0:
        {
            [self fetchFeeds];
            break;
        }
        case 1:
        {
            [self fetchNotifications];
            break;
        }
        case 2:
        {
            [self fetchMessages];
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void) sendFeed:(NSString *)txt{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:txt?txt:@"", @"msg", @"", @"from", nil];
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiSendFeed:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 NSString *d = [resp objectForKey:@"d"];
                 Log(@"%@", d);
                 MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
                 alert.customView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Icon"]];
                 alert.mode = MBProgressHUDModeCustomView;
                 alert.labelText = @"发送成功";
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.view addSubview:alert];
                     [alert show:YES];
                     [alert hide:YES afterDelay:2.0];
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
             MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
             alert.customView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Icon"]];
             alert.mode = MBProgressHUDModeCustomView;
             alert.labelText = @"发送失败";
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.view addSubview:alert];
                 [alert show:YES];
                 [alert hide:YES afterDelay:2.0];
             });
         });
     }];
}

- (void)fetchFeeds {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", self.pageDown], @"page", nil];

    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiFeedCenter:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
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


- (void)fetchNotifications {
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiNotificationCenter:nil withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 NSArray *d = [resp objectForKey:@"d"];
                 self.dataSource = [NSMutableArray arrayWithArray:d];
                 
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
         });
     }];
}

- (void)fetchMessages {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", self.pageDown], @"page", nil];
    
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiMessageCenter:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         //         [self performSelectorOnMainThread:@selector(stopAction) withObject:nil waitUntilDone:[NSThread isMainThread]];
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
             //             [self performSelectorOnMainThread:@selector(stopAction) withObject:nil waitUntilDone:[NSThread isMainThread]];
         });
     }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self sendFeed:[[alertView textFieldAtIndex:0] text]];
    }
}

- (IBAction)createButtonTapped: (id) sender {
    NSInteger showingSegment = self.selectedIndex;
    switch (showingSegment) {
        case 0:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发布状态"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"发布", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
            break;
        }
        case 1:
        {
            break;
        }
        case 2:
        {
            HJProfilePickerViewController *pPicker = [[HJProfilePickerViewController alloc] initWithNibName:@"HJProfilePickerViewController" bundle:nil];
            pPicker.selectionType = HJProfilePickerSelectionTypeSingle;
            pPicker.delegate = self;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pPicker];
            [self presentModalViewController:navController animated:YES];
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)profileSelected:(NSArray *)selectedProfiles {
    NSDictionary *profile = [selectedProfiles objectAtIndex:0];
    HJChatViewController *viewController = [[HJChatViewController alloc] initWithNibName:@"HJChatViewController" bundle:nil];
    viewController.withId = [profile objectForKey:@"profile_id"];
    viewController.title = [profile objectForKey:@"name"];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
