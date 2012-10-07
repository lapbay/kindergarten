//
//  HJFeedViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HJFeedCenterViewController.h"
#import "MIRequestManager+API.h"
#import "HJFeedCellDefault.h"
#import "HJFeedViewController.h"
#import "HJProfileViewController.h"
#import "HJTaskViewController.h"
#import "HJNotificationCenterViewController.h"
#import "HJTaskSeriesViewController.h"

@interface HJFeedCenterViewController ()

@end

@implementation HJFeedCenterViewController
@synthesize contentView = _contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"消息中心", @"Feed");
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
    
    [self initRefreshView:self.contentView];
    isLoading = YES;
    [self refreshFooterTriggered];
}

//- (IBAction)profileButtonTapped : (id) sender {
//    HJProfileViewController *profile = [[HJProfileViewController alloc] initWithNibName:@"HJProfileViewController" bundle:nil];
//    profile.profileId = @"5031f3280b11356772000005";
//    [self.navigationController pushViewController:profile animated:YES];
//}




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

    static NSString *CellIdentifier = @"HJFeedCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
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
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
    Log(@"%@", cellData);
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

@end
