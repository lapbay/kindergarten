//
//  HJTaskCenterViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/13/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "HJTaskCenterViewController.h"
#import "HJCreateTaskViewController.h"
#import "HJTaskSeriesViewController.h"
#import "HJTaskViewController.h"
#import "MIRequestManager+API.h"
#import "HJTaskCell.h"
#import "MBProgressHUD.h"

@interface HJTaskCenterViewController ()

@end

@implementation HJTaskCenterViewController
@synthesize contentView = _contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"任务中心", @"Task Center");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.sourceType = 0;
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"发布新任务", @"Create Task")
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(createButtonTapped:)];
    self.navigationItem.rightBarButtonItem = NavButton;
    
    self.contentView.delegate = self;
    self.contentView.dataSource = self;
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
    [super viewWillAppear:animated];
    switch (self.sourceType) {
        case 0:
        {
            [self queryTasks:@{@"scope": @"all"}];
            break;
        }
        case 1:
        {
            [self queryTasks:@{@"scope": @"parted"}];
            break;
        }
        case 2:
        {
            [self queryTasks:@{@"scope": @"created"}];
            break;
        }
        default:
            break;
    }
}

- (IBAction)createButtonTapped : (id) sender {
    UIActionSheet *select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发布独立任务", @"发布系列任务", nil];
    [select showFromBarButtonItem:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"%i", buttonIndex);
    }else{
        switch (buttonIndex) {
            case 0:
            {
                HJCreateTaskViewController *creator = [[HJCreateTaskViewController alloc] initWithNibName:@"HJCreateTaskViewController" bundle:nil];
                creator.type = HJTaskTypeIndependentCreate;
                [self.navigationController pushViewController:creator animated:YES];
                break;
            }
            case 1:
            {
                HJTaskSeriesViewController *creator = [[HJTaskSeriesViewController alloc] initWithNibName:@"HJTaskSeriesViewController" bundle:nil];
                creator.type = HJTaskTypeSeriesCreate;
                creator.allowToShowEditors = YES;
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:creator];
                [self presentModalViewController:navController animated:YES];

//                [self.navigationController pushViewController:creator animated:YES];
                break;
            }
            default:
                break;
        }
    }
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
}


- (IBAction)segmentAction: (UISegmentedControl *) sender {
    NSInteger showingSegment = sender.selectedSegmentIndex;
    NSDictionary *params;
    if (showingSegment == 0) {
        params = @{@"scope": @"all"};
    }else if (showingSegment == 1) {
        params = @{@"scope": @"recommend"};
    }else {
        params = @{@"scope": @"created"};
    }
    [self queryTasks:params];
}

- (void)queryTasks:(NSDictionary *)params {
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

@end
