//
//  MIAboutViewController.m
//  photo
//
//  Created by Wu Chang on 7/24/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import "MIAboutViewController.h"
#import "MIWebViewController.h"

@interface MIAboutViewController ()

@end

@implementation MIAboutViewController
@synthesize data, hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"关于", @"About");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.data = [NSMutableArray arrayWithObjects:
                     [NSArray arrayWithObjects: @"支持信息", @"中央人民政府", nil],
                     [NSArray arrayWithObjects: @"支持电话", @"110 119 120", nil],
                     [NSArray arrayWithObjects: @"版本", @"1.0", nil],
                     nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:self.hud];
    //    self.hud.delegate = self;
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
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    NSArray *cellData = [self.data objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [cellData objectAtIndex:0];
    cell.detailTextLabel.text = [cellData objectAtIndex:1];
    cell.textLabel.backgroundColor = [UIColor clearColor];
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            break;
        }
        case 1:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"现在拨打 400 支持电话吗？"
                                                            message:@"客服工作时间：每日9:00-18:00"
                                                           delegate:nil
                                                  cancelButtonTitle:@"否"
                                                  otherButtonTitles:@"是", nil];
            alert.delegate = self;
            [alert show];
            break;
        }
        case 2:
        {
            MIWebViewController *version = [[MIWebViewController alloc] initWithNibName:@"MIWebViewController" bundle:nil];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:version animated:YES];
            [version loadWebPageWithURLString:@"http://www.google.com"];
            break;
        }
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)connectionDidFinishLoading:(NSMutableDictionary *) response {
    [self.hud hide:YES];
    NSInteger c = [[response objectForKey:@"c"] intValue];
    if (c == 200) {
        NSString *d = [response objectForKey:@"d"];
        MBProgressHUD *alert = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:alert];
        alert.mode = MBProgressHUDModeDeterminate;
        alert.labelText = d;
        [alert show:YES];
        [alert hide:YES afterDelay:3];
        
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
        NSString *d = [response objectForKey:@"d"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:d
                                                       delegate:nil
                                              cancelButtonTitle:@"不更新"
                                              otherButtonTitles:@"更新", nil];
        [alert show];
    }
}

@end
