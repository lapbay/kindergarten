//
//  MIMoreViewController.m
//  photo
//
//  Created by Wu Chang on 7/24/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import "MIMoreViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MIUserViewController.h"
#import "MIAboutViewController.h"
#import "UMFeedback.h"

@interface MIMoreViewController ()

@end

@implementation MIMoreViewController
@synthesize hud, data, appStoreURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"设置", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.data = [NSMutableArray arrayWithObjects:
                     [NSMutableArray arrayWithObjects:
                      [NSMutableArray arrayWithObjects:
                       @"用户反馈",
                       nil],
                      [NSMutableArray arrayWithObjects:
                       @"检查新版本",
                       nil],
                      [NSMutableArray arrayWithObjects:
                       @"去 App Store 评分",
                       nil],
                      nil],
                     [NSMutableArray arrayWithObjects:
                      [NSMutableArray arrayWithObjects:
                       @"当前版本",
                       @"1.0.0",
                       nil],
                      nil],
                     nil];
        self.appStoreURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=505444421";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"退出登录", @"Signout")
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(logoutButtonTapped:)];
    self.navigationItem.rightBarButtonItem = NavButton;

    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:self.hud];
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

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.data.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
//}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.data objectAtIndex:section] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    // Configure the cell.
    NSArray *cellData = [[self.data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [cellData objectAtIndex:0];
    if (cellData.count > 1) {
        cell.detailTextLabel.text = [cellData objectAtIndex:1];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.hidesBottomBarWhenPushed = YES;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                [UMFeedback showFeedback:self withAppkey:UMENG_KEY];
                break;
            }
            case 1:
            {
                break;
            }
            case 2:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=548258391"]];
                break;
            }
            default:
            {
                break;
            }
        }
    }
    self.hidesBottomBarWhenPushed = NO;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)connectionDidFinishLoading:(NSMutableDictionary *) response {
    [self.hud hide:YES];
    NSInteger c = [[response objectForKey:@"c"] intValue];
    if (c == 200) {
        NSDictionary *d = [response objectForKey:@"d"];
        BOOL needUpgrade = [[d objectForKey:@"need_upgrade"] boolValue];
        self.appStoreURL = [d objectForKey:@"url"];
        if (needUpgrade) {
            NSArray *new = [d objectForKey:@"whats_new"];
            NSString *msg = [new componentsJoinedByString:@"\n"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有新版本 %@", [d objectForKey:@"newest_ver"]]
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"不更新"
                                                  otherButtonTitles:@"更新", nil];
            [alert show];
        }else{
            MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:alert];
            alert.mode = MBProgressHUDModeDeterminate;
            alert.labelText = @"已经是最新版本";
            [alert show:YES];
            [alert hide:YES afterDelay:1];
        }
        
    }else if (c == 500) {
        NSString *d = [response objectForKey:@"d"];
        MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:alert];
        alert.customView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"rejected"]];
        alert.mode = MBProgressHUDModeCustomView;
        alert.labelText = d;
        [alert show:YES];
        [alert hide:YES afterDelay:3];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                        message:@"无法取得新版本信息"
                                                       delegate:nil
                                              cancelButtonTitle:@"不更新"
                                              otherButtonTitles:@"更新", nil];
        [alert show];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.hud hide:YES];
    NSString *d = [error localizedDescription];
    MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:alert];
    alert.customView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"rejected"]];
    alert.mode = MBProgressHUDModeCustomView;
    alert.labelText = d;
    [alert show:YES];
    [alert hide:YES afterDelay:3];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appStoreURL]];
    }
}


- (IBAction)logoutButtonTapped : (id) sender {
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiUserLogout:nil withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //[self.hud hide:YES];
         });
         
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200 || c == 201) {
                 //                 NSDictionary *d = [resp objectForKey:@"d"];
                 @try {
                     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                     [userDefaults setBool:NO forKey:@"login"];
                     [userDefaults removeObjectForKey:@"token"];
                     [userDefaults synchronize];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"MIShouldAddLoginView" object:nil];
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
                 NSDictionary *d = [resp objectForKey:@"d"];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                                 message:[d objectForKey:@"message"]
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
