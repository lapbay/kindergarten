//
//  HJMessageCenterViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HJMessageCenterViewController.h"
#import "MIRequestManager+API.h"
#import "HJFeedCellDefault.h"
#import "HJFeedViewController.h"
#import "HJProfileViewController.h"
#import "HJTaskViewController.h"
#import "HJNotificationCenterViewController.h"
#import "HJTaskSeriesViewController.h"
#import "UIImageView+Web.h"
#import "HJChatViewController.h"
#import "HJProfilePickerViewController.h"

@interface HJMessageCenterViewController ()

@end

@implementation HJMessageCenterViewController
@synthesize contentView = _contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"私信", @"Message");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.dataSource = [NSMutableArray array];
        self.showFooter = NO;
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(createButtonTapped:)];
    self.navigationItem.rightBarButtonItem = NavButton;

    self.contentView.delegate = self;
    self.contentView.dataSource = self;
    
//    [self initRefreshView:self.contentView];
//    isLoading = YES;
    [self refreshFooterTriggered];
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

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
}


- (IBAction)createButtonTapped: (id) sender {
    HJProfilePickerViewController *pPicker = [[HJProfilePickerViewController alloc] initWithNibName:@"HJProfilePickerViewController" bundle:nil];
    pPicker.selectionType = HJProfilePickerSelectionTypeSingle;
    pPicker.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pPicker];
    [self presentModalViewController:navController animated:YES];
}

- (void)profileSelected:(NSArray *)selectedProfiles {
    NSDictionary *profile = [selectedProfiles objectAtIndex:0];
    HJChatViewController *viewController = [[HJChatViewController alloc] initWithNibName:@"HJChatViewController" bundle:nil];
    viewController.withId = [profile objectForKey:@"profile_id"];
    viewController.title = [profile objectForKey:@"name"];
    [self.navigationController pushViewController:viewController animated:YES];
}

//- (void) refreshHeaderTriggered {
//    [self performSelector:@selector(stopHeaderAction) withObject:nil afterDelay:1.0];
//}

- (void)refreshFooterTriggered {
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

@end
