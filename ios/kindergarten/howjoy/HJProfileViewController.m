//
//  HJPeopleViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/13/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HJProfileViewController.h"
#import "MIRequestManager+API.h"
#import "HJSearchViewController.h"
#import "HJFeedCellDefault.h"
#import "HJTaskCell.h"
#import "HJTaskSeriesViewController.h"
#import "HJTaskViewController.h"
#import "HJChatViewController.h"
#import "MBProgressHUD.h"


@interface HJProfileViewController ()

@end

@implementation HJProfileViewController
@synthesize hjContentType = _hjContentType;
@synthesize contentView = _contentView;
@synthesize contentSwitchSegment;
@synthesize nameLabel;
@synthesize rankLabel;
@synthesize levelLabel;
@synthesize introductionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"个人资料", @"Profile");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.    
    self.contentView.delegate = self;
    self.contentView.dataSource = self;

    if (!self.shouldHideButtons) {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonTapped:)];
        self.navigationItem.leftBarButtonItem = leftButton;
    }
    if (!self.profileId || [self.profileId isEqualToString:@"self"] || [self.profileId isEqualToString:[[MIStorage sharedManager] currentUserId]]) {
        self.profileId = @"self";
        UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"修改资料", @"Edit Profile") style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonTapped:)];
        self.navigationItem.rightBarButtonItem = NavButton;
    }

    //    if ([self.profileId isEqualToString:[[MIStorage sharedManager] currentUserId]] || [self.profileId isEqualToString:@"self"]) {
    //        [self fillProfileData: nil];
    //        [self tabDidSwitch:self.contentSwitchSegment];
    //    }
    NSDictionary *params = @{@"id": self.profileId};
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiProfile:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
                     NSDictionary *d = [resp objectForKey:@"d"];
                     Log(@"%@", d);
                     NSMutableDictionary *profile = [NSMutableDictionary dictionaryWithDictionary:[d objectForKey:@"profile"]];
                     self.profileData = profile;
                     self.dataSource = [d objectForKey:@"data"];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self fillProfileData:profile];
                         
                         int relation = [[d objectForKey:@"relation"] intValue];
                         NSLog(@"relation: %i", relation);
                         
                         switch (relation) {
                             case 0:
                             {
                                 //somebody not followed
                                 UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"加为好友", @"Add Friend") style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonTapped:)];
                                 self.navigationItem.rightBarButtonItem = NavButton;
                                 break;
                             }
                             case 1:
                             {
                                 //self, do nothing
                                 break;
                             }
                             case 2:
                             {
                                 //a friend
                                 UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"移除好友", @"Unfriend") style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowButtonTapped:)];
                                 self.navigationItem.rightBarButtonItem = NavButton;
                                 self.messageButton.hidden = NO;
                                 break;
                             }
                             case 3:
                             {
                                 //current user sent a request to this user
                                 UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"已发送请求", @"Friend Request Sent") style:UIBarButtonItemStyleBordered target:self action:@selector(sentButtonTapped:)];
                                 self.navigationItem.rightBarButtonItem = NavButton;
                                 break;
                             }
                             case 4:
                             {
                                 //this user sent a request to current user
                                 UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"回复请求", @"Respond to Friend Request") style:UIBarButtonItemStyleBordered target:self action:@selector(respondButtonTapped:)];
                                 self.navigationItem.rightBarButtonItem = NavButton;
                                 break;
                             }
                             default:
                                 break;
                         }
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

- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setRankLabel:nil];
    [self setLevelLabel:nil];
    [self setIntroductionLabel:nil];
    [self setContentSwitchSegment:nil];
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
    [super viewWillAppear:animated];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat heights = 0;
    switch (self.hjContentType) {
        case HJTableContentFeedType:
            heights = 80.0;
            break;
        case HJTableContentFriendType:
            heights = 44.0;
            break;
           
        default:
            heights= 120.0;
            break;
    }
    
    return heights;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger counter = self.dataSource.count;
//    switch (self.hjContentType) {
//        case HJTableContentFeedType:
//            counter = [self.dataSource count];
//            break;
//            
//        default:
//            counter= [[self.dataSource objectAtIndex:section] count];
//            break;
//    }
    
    return counter;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.hjContentType) {
        case HJTableContentFeedType:{
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
                case 1:
                {
                    cell.contentView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
                    break;
                }
                case 2:
                {
                    cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                    break;
                }
                case 3:
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
            return cell;
        }
            
            break;
        case HJTableContentTaskType:{
            static NSString *CellIdentifier = @"HJTaskCell";
            
            //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //    if (cell == nil) {
            //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            //    }
            
            HJTaskCell *cell = (HJTaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HJTaskCell" owner:nil options:nil];
                for(id currentObject in topLevelObjects) {
                    if([currentObject isKindOfClass:[HJTaskCell class]]) {
                        cell = (HJTaskCell *) currentObject;
                        break;
                    }
                }
                //cell.contentView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:240.0f/255.0f blue:1.0f alpha:1.0f];
                //cell.titleLabel.backgroundColor = [UIColor clearColor];
            }
            
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = [cellData objectForKey:@"name"];
            cell.placeLabel.text = [cellData objectForKey:@"place"];
            cell.timeLabel.text = [cellData objectForKey:@"start_at"];
            cell.countLabel.text = [[cellData objectForKey:@"count"] stringValue];
            
            [self configureCell:cell atIndexPath:indexPath];
            return cell;

        }
            break;
        case HJTableContentFriendType:{
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [cellData objectForKey:@"name"];
            
            return cell;
        }
            break;
        default:
            break;
    }
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 0) {
//        NSArray *cellData = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//        cell.textLabel.text = [cellData objectAtIndex:0];
//        id value = [cellData objectAtIndex:1];
//        cell.detailTextLabel.text = [value isKindOfClass:[NSNumber class]] ? [value stringValue] : value;
    }else if (indexPath.section == 1) {
        NSDictionary *cellData = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.text = [cellData objectForKey:@"title"];
        cell.detailTextLabel.text = [cellData objectForKey:@"content"];
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.hjContentType) {
        case HJTableContentFeedType:
        {
            break;
        }
        case HJTableContentTaskType:
        {
            NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
            NSInteger type = [[cellData objectForKey:@"type"] integerValue];
            if (type == 0) {
                HJTaskViewController *task = [[HJTaskViewController alloc] initWithNibName:@"HJTaskViewController" id:[cellData objectForKey:@"_id"]];
                [self.navigationController pushViewController:task animated:YES];
            }else if (type == 1) {
                HJTaskSeriesViewController *task = [[HJTaskSeriesViewController alloc] initWithNibName:@"HJTaskSeriesViewController" bundle:nil];
                task.type = HJTaskTypeView;
                task.taskId = [cellData objectForKey:@"_id"];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:task];
                [self presentModalViewController:navController animated:YES];
            }
            break;
        }
        case HJTableContentPhotoType:
        {
            break;
        }
        default:
            break;
    }
    [self.contentView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)followButtonTapped : (id) sender {
    NSDictionary *params = @{@"id": self.profileId};
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiFriendRequest:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
//                     NSDictionary *d = [resp objectForKey:@"d"];
//                     NSLog(@"%@", d);

                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Friend Request Sent", @"Friend Request Sent") style:UIBarButtonItemStyleBordered target:self action:@selector(sentButtonTapped:)];
                         self.navigationItem.rightBarButtonItem = nil;
                         self.navigationItem.rightBarButtonItem = NavButton;
                         //[self.contentView reloadData];
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
         });
     }];
}

- (IBAction)unfollowButtonTapped : (id) sender {
    NSDictionary *params = @{@"id": self.profileId};
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiFriendRemove:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
//                     NSDictionary *d = [resp objectForKey:@"d"];
//                     NSLog(@"%@", d);
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add Friend", @"Add Friend") style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonTapped:)];
                         self.navigationItem.rightBarButtonItem = nil;
                         self.navigationItem.rightBarButtonItem = NavButton;
                         //[self.contentView reloadData];
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
         });
     }];
}

- (IBAction)searchButtonTapped: (id) sender{
    HJSearchViewController *search = [[HJSearchViewController alloc] initWithNibName:@"HJSearchViewController" bundle:nil];
    search.type = HJSearchViewTypeProfile;
    //search.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:search];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:search action:@selector(searchBarCancelButtonClicked:)];
    search.navigationItem.leftBarButtonItem = leftButton;
    [self presentModalViewController:navController animated:YES];
}

- (IBAction)sentButtonTapped: (id) sender{
    UIActionSheet *select = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"取消请求" otherButtonTitles: nil];
    [select showFromBarButtonItem:sender animated:YES];
}

- (IBAction)respondButtonTapped: (id) sender{
    UIActionSheet *select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"接受", @"忽略", nil];
    [select showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"cancel at index %i", buttonIndex);
    }else if (buttonIndex == actionSheet.destructiveButtonIndex) {
    }else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id": self.profileId}];
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:@"Accept"]) {
            [params setObject:@"accept" forKey:@"act"];
        }else if ([title isEqualToString:@"Ignore"]) {
            [params setObject:@"ignore" forKey:@"act"];
        }
        
        MIRequestManager *manager = [MIRequestManager requestManager];
        [manager apiFriendResponse:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
         {
             if ([rData length] > 0 && error == nil){
                 //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
                 NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
                 NSInteger c = [[resp objectForKey:@"c"] intValue];
                 if (c == 200) {
//                     NSDictionary *d = [resp objectForKey:@"d"];
//                     NSLog(@"%@", d);
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIBarButtonItem *NavButton;
                         if ([title isEqualToString:@"Accept"]) {
                             NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Unfriend", @"Unfriend") style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowButtonTapped:)];
                         }else if ([title isEqualToString:@"Ignore"]) {
                             NavButton= [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add Friend", @"Add Friend") style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonTapped:)];
                         }
                         self.navigationItem.rightBarButtonItem = nil;
                         self.navigationItem.rightBarButtonItem = NavButton;
                         //[self.contentView reloadData];
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
}
- (void)fillProfileData:(NSDictionary *)pro{
    if (pro) {
        self.nameLabel.text = [pro objectForKey:@"name"];
        self.rankLabel.text = [[pro objectForKey:@"rank"] isKindOfClass:[NSNumber class]] ? [[pro objectForKey:@"rank"] stringValue] : [pro objectForKey:@"rank"];
        self.levelLabel.text = [[pro objectForKey:@"level"] isKindOfClass:[NSNumber class]] ? [[pro objectForKey:@"level"] stringValue] : [pro objectForKey:@"level"];
        self.introductionLabel.text = [pro objectForKey:@"name"];
    }else{
        self.nameLabel.text = [MIStorage sharedManager].currentUserName;
        self.rankLabel.text = [MIStorage sharedManager].currentUserRank;
        self.levelLabel.text = [MIStorage sharedManager].currentUserLevel;
        self.introductionLabel.text = [MIStorage sharedManager].currentUserIntroducation;
    }
}

- (IBAction)tabDidSwitch:(id)sender {
    UISegmentedControl * control = (UISegmentedControl*)sender;
    self.hjContentType = control.selectedSegmentIndex ;
    if (control.selectedSegmentIndex==0) {
        [self fetchFeeds];
    }else if (control.selectedSegmentIndex ==1) {
        [self fetchTasks];
    }else if (control.selectedSegmentIndex ==2) {
        [self fetchFriends];
    }else if (control.selectedSegmentIndex ==3) {
    }

}
- (void) fetchFeeds{
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiFeedCenter:nil withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
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
- (void) fetchTasks{
    NSDictionary * params = @{ @"scope" : @"parted" };
    MIRequestManager *manager = [MIRequestManager requestManager];
    
    [manager apiTaskCenter:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
                     NSArray *d = [resp objectForKey:@"d"];
                     self.dataSource = [NSMutableArray arrayWithArray:d];
                     //Log(@"%@", self.dataSource);
                     
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
- (void) fetchPhotos{
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiFeedCenter:nil withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
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
- (void) fetchFriends{
    NSDictionary *params = @{@"type": @"0", @"id": self.profileId};
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiFriendsList:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
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

- (IBAction)editButtonTapped:(id)sender {
    Log(@"%@", @"should edit profile");
}

- (IBAction)messageButtonTapped:(id)sender {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发私信"
//                                                    message:[NSString stringWithFormat:@"%@", @"somebody"]
//                                                   delegate:self
//                                          cancelButtonTitle:@"取消"
//                                          otherButtonTitles:@"确定", nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alert show];
    HJChatViewController *viewController = [[HJChatViewController alloc] initWithNibName:@"HJChatViewController" bundle:nil];
    viewController.withId = self.profileId;
    viewController.title = [self.profileData objectForKey:@"name"];
    [self.navigationController pushViewController:viewController animated:YES];
}
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    UITextField *textField = [alertView textFieldAtIndex:0];
//    if ([textField.text length] <= 0 || buttonIndex == 0){
//        return;
//    }
//    if (buttonIndex == 1) {
//        [self sendMessage:textField.text];
//    }
//}
//- (void) sendMessage:(NSString *)txt{
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:txt?txt:@"", @"msg", self.profileId, @"to", nil];
//    MIRequestManager *manager = [MIRequestManager requestManager];
//    [manager apiSendMessage:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
//     {
//         if ([rData length] > 0 && error == nil){
//             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
//             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
//             NSInteger c = [[resp objectForKey:@"c"] intValue];
//             if (c == 200) {
//                 NSString *d = [resp objectForKey:@"d"];
//                 Log(@"%@", d);
//                 MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
//                 alert.customView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Icon"]];
//                 alert.mode = MBProgressHUDModeCustomView;
//                 alert.labelText = @"私信发送成功";
//                 
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [self.view addSubview:alert];
//                     [alert show:YES];
//                     [alert hide:YES afterDelay:2.0];
//                 });
//                 @try {
//                 }
//                 @catch (NSException *exception) {
//                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
//                                                                     message:@"服务器返回数据错误"
//                                                                    delegate:nil
//                                                           cancelButtonTitle:@"OK"
//                                                           otherButtonTitles:nil, nil];
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         [alert show];
//                     });
//                 }
//                 @finally {
//                     
//                 }
//             }else {
//                 NSString *msg;
//                 if ([resp objectForKey:@"d"]) {
//                     if ([[resp objectForKey:@"d"] isKindOfClass:[NSString class]]) {
//                         msg = [resp objectForKey:@"d"];
//                     }else if ([[resp objectForKey:@"d"] isKindOfClass:[NSDictionary class]]) {
//                         msg = [[resp objectForKey:@"d"] objectForKey:@"message"];
//                     }
//                 }else if ([resp objectForKey:@"error"]) {
//                     msg = [resp objectForKey:@"error"];
//                 }else if ([resp objectForKey:@"message"]) {
//                     msg = [resp objectForKey:@"message"];
//                 }else{
//                     msg = @"服务器未返回可读的错误信息";
//                 }
//                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
//                                                                 message:msg
//                                                                delegate:nil
//                                                       cancelButtonTitle:@"OK"
//                                                       otherButtonTitles:nil, nil];
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [alert show];
//                 });
//             }
//         }
//     } withErrorHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//     {
//         dispatch_async(dispatch_get_main_queue(), ^{
//         });
//     }];
//}

@end
