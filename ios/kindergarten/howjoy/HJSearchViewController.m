//
//  HJSearchViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/27/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJSearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HJProfileViewController.h"
#import "HJTaskSeriesViewController.h"
#import "HJTaskViewController.h"

@interface HJSearchViewController ()

@end

@implementation HJSearchViewController
@synthesize contentView = _contentView;
@synthesize searchBar = _searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"搜索好友", @"Find Friends");
        self.dataSource = [NSMutableArray array];
        self.type = HJSearchViewTypeProfile;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:gestureRecognizer];
    for(id cc in [self.searchBar subviews]){
        if([cc isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)cc;
            //[btn setTitle:@"搜索" forState:UIControlStateNormal];
            btn.enabled = YES;
            break;
        }
    }

    [self.searchBar setDelegate:self];
    if (self.type == HJSearchViewTypeTask) {
        self.searchBar.placeholder= @"搜索任务";
    }
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



-(void)hideKeyboard {
//    [self.searchBar resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.searchBar becomeFirstResponder];
    [super viewWillAppear:animated];
//    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *) bar{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchConfirmed:)]) {
        [self.delegate performSelector:@selector(searchConfirmed:) withObject:self.searchBar.text];
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [self doSearch];
    }
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) bar{
    [self.searchBar resignFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

- (void) doSearch {
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithObjectsAndKeys:self.searchBar.text, @"kw", nil];
    if (self.type == HJSearchViewTypeProfile) {
        [params setObject:@"profile" forKey:@"scope"];
    }else if (self.type == HJSearchViewTypeTask) {
        [params setObject:@"task" forKey:@"scope"];
    }
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiSearches:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
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
    NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];

    if (self.type == HJSearchViewTypeProfile) {
        HJProfileViewController *profile = [[HJProfileViewController alloc] initWithNibName:@"HJProfileViewController" bundle:nil];
        profile.shouldHideButtons = YES;
        profile.profileId = [cellData objectForKey:@"_id"];
        [self.navigationController pushViewController:profile animated:YES];
    }else if (self.type == HJSearchViewTypeTask) {
        switch ([[cellData objectForKey:@"type"] intValue]) {
            case 0:
            {
                HJTaskViewController *task = [[HJTaskViewController alloc] initWithNibName:@"HJTaskViewController" bundle:nil];
                task.taskId = [cellData objectForKey:@"_id"];
                [self.navigationController pushViewController:task animated:YES];
                break;
            }
            case 1:
            {
                HJTaskSeriesViewController *task = [[HJTaskSeriesViewController alloc] initWithNibName:@"HJTaskSeriesViewController" bundle:nil];
                task.type = HJTaskTypeView;
                task.taskId = [cellData objectForKey:@"_id"];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:task];
                [self presentModalViewController:navController animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

@end
