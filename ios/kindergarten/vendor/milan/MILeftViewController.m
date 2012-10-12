//
//  MILeftViewController.m
//  bid
//
//  Created by com milan on 7/5/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import "MILeftViewController.h"
#import "IIViewDeckController.h"
#import "MILoginViewController.h"

#import "HJNotificationCenterViewController.h"
#import "HJMessageCenterViewController.h"
#import "HJFeedCenterViewController.h"
#import "HJRecordViewController.h"
#import "HJTaskCenterViewController.h"
#import "HJProfileViewController.h"
#import "HJPropsViewController.h"
#import "HJSearchViewController.h"
//#import "HJMoreViewController.h"
#import "MIMoreViewController.h"
#import "HJProfileHeaderViewCell.h"
#import "HJScanViewController.h"

@interface MILeftViewController ()

@end

@implementation MILeftViewController
@synthesize data;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"菜单", @"Menu");

        self.data = [NSMutableArray arrayWithObjects:
                     [NSMutableArray arrayWithObjects:@"个人资料", nil],
                     [NSMutableArray arrayWithObjects:@"任务中心", @"所有", @"推荐", nil],
                     [NSMutableArray arrayWithObjects:@"情报站", @"消息", @"通知", @"私信", nil],
//                     [NSMutableArray arrayWithObjects:@"搜索", @"好友", @"任务", nil],
                     [NSMutableArray arrayWithObjects:@"搜索", @"好友", nil],
                     [NSMutableArray arrayWithObjects:@"更多", @"设置", nil],
                     nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldReloadViews:) name:@"MILoginDidFinishedSuccessfully" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView.scrollsToTop = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)shouldReloadViews:(NSNotification *) n{
    Log(@"%@", n);
    //[self.tableView reloadData];
//    [self.viewDeckController toggleLeftView];
//    [self tableView: self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 36.0;
    if (indexPath.section == 0) {
        height = 128.0;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 1;
    if (section != 0) {
        rows = [[self.data objectAtIndex:section] count] - 1;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [MIStorage sharedManager].currentUserName;
    }
    return [[self.data objectAtIndex:section] objectAtIndex:0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
//    NSLog(@"%i, %i", indexPath.section, indexPath.row);
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *CellIdentifier = @"Cell";
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HJProfileHeaderViewCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects) {
                if([currentObject isKindOfClass:[HJProfileHeaderViewCell class]]) {
                    cell = (HJProfileHeaderViewCell *) currentObject;
                    break;
                }
            }
        }
        [[(HJProfileHeaderViewCell *)cell nameLabel] setText:[MIStorage sharedManager].currentUserName];
        [[(HJProfileHeaderViewCell *)cell levelLabel] setText:[MIStorage sharedManager].currentUserLevel];
        [[(HJProfileHeaderViewCell *)cell rankLabel] setText:[MIStorage sharedManager].currentUserRank];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [MIStorage sharedManager].currentUserName];
    }else{
        static NSString *CellIdentifier = @"HJMenuViewCell";
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSArray *cellData = [self.data objectAtIndex:indexPath.section];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [cellData objectAtIndex:indexPath.row + 1]];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {

        if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
            UIViewController *viewController;

            switch (indexPath.section) {
                case 0:
                {
                    viewController = [[HJProfileViewController alloc] initWithNibName:@"HJProfileViewController" bundle:nil];
                    break;
                }
                case 1:
                {
                    viewController = [[HJTaskCenterViewController alloc] initWithNibName:@"HJTaskCenterViewController" bundle:nil];
                    ((HJTaskCenterViewController *)viewController).sourceType = indexPath.row;
                    [((HJTaskCenterViewController *)viewController) shouldQueryApi:nil];
                    break;
                }
                case 2:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            viewController = [[HJFeedCenterViewController alloc] initWithNibName:@"HJFeedCenterViewController" bundle:nil];
                            break;
                        }
                        case 1:
                        {
                            viewController = [[HJNotificationCenterViewController alloc] initWithNibName:@"HJNotificationCenterViewController" bundle:nil];
                            break;
                        }
                        case 2:
                        {
                            viewController = [[HJMessageCenterViewController alloc] initWithNibName:@"HJMessageCenterViewController" bundle:nil];
                            break;
                        }
                        default:
                            break;
                    }
                    break;
                }
                case 3:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            viewController = [[HJSearchViewController alloc] initWithNibName:@"HJSearchViewController" bundle:nil];
                            ((HJSearchViewController *)viewController).type = HJSearchViewTypeProfile;
                            break;
                        }
                        case 1:
                        {
                            viewController = [[HJSearchViewController alloc] initWithNibName:@"HJSearchViewController" bundle:nil];
                            ((HJSearchViewController *)viewController).type = HJSearchViewTypeTask;
                            break;
                        }
                        default:
                            break;
                    }
                    break;
                }
                case 4:
                {
                    viewController = [[MIMoreViewController alloc] initWithNibName:@"MIMoreViewController" bundle:nil];
                    break;
                }
                default:
                    break;
            }
            UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
            viewController.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
            controller.centerController = nil;
            controller.centerController = centerController;
            
            UIViewController *cc = ((UINavigationController*) controller.centerController).topViewController;
            cc.navigationItem.title = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        }
        [NSThread sleepForTimeInterval:(300+arc4random()%700)/1000000.0];
    }];
}

- (void)showFirstCenterView {
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        UIViewController *viewController = [[HJTaskCenterViewController alloc] initWithNibName:@"HJTaskCenterViewController" bundle:nil];
        UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
        viewController.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
        controller.centerController = nil;
        controller.centerController = centerController;
        
        UIViewController *cc = ((UINavigationController*) controller.centerController).topViewController;
        cc.navigationItem.title = [[self.data objectAtIndex:0] objectAtIndex:0];
    }];
}

- (IBAction)firstButtonTapped:(id)sender {
    self.viewDeckController.shouldFireViewMethods = NO;
    HJPropsViewController *viewController = [[HJPropsViewController alloc] initWithNibName:@"HJPropsViewController" bundle:nil];
    UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
    //centerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:centerController animated:YES];
}

- (IBAction)secondButtonTapped:(id)sender {
    self.viewDeckController.shouldFireViewMethods = NO;
    HJRecordViewController *viewController = [[HJRecordViewController alloc] initWithNibName:@"HJRecordViewController" bundle:nil];
    viewController.shouldAddCancelButton = YES;
    viewController.type = HJRecordTypeFinish;
    UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
    //centerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:centerController animated:YES];
    [viewController initDataSource:nil];
}

- (IBAction)thirdButtonTapped:(id)sender {
    self.viewDeckController.shouldFireViewMethods = NO;
    HJScanViewController *viewController = [HJScanViewController new];
    UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
    //centerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:centerController animated:YES];

//    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
//        MIMoreViewController *viewController = [[MIMoreViewController alloc] initWithNibName:@"MIMoreViewController" bundle:nil];
//        UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
//        viewController.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
//        controller.centerController = nil;
//        controller.centerController = centerController;
//        
//        UIViewController *cc = ((UINavigationController*) controller.centerController).topViewController;
//        cc.navigationItem.title = @"More";
//    }];
}

@end
