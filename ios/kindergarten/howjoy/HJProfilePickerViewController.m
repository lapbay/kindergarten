//
//  HJProfilePickerViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/30/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJProfilePickerViewController.h"
#import "MIRequestManager+API.h"

@interface HJProfilePickerViewController ()

@end

@implementation HJProfilePickerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.selectionType = HJProfilePickerSelectionTypeMultiple;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"选择好友", @"Pick Friends");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selected = [NSMutableDictionary dictionary];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"确定", @"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = NavButton;
}
- (IBAction)cancelButtonTapped : (id) sender {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    Log(@"%@", self.navigationController.navigationBar.backItem);
    if (!self.navigationItem.leftBarButtonItem && !self.navigationController.navigationBar.backItem) {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", @"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonTapped:)];
        self.navigationItem.leftBarButtonItem = leftButton;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDictionary *params = @{@"type": @"0", @"id": @"self"};
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
                     [self.tableView reloadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.selectionType == HJProfilePickerSelectionTypeSingle) {
        for (NSIndexPath *ip in self.selected){
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:ip];
            selectedCell.accessoryType = UITableViewCellAccessoryNone;
            selectedCell = nil;
        }
        [self.selected removeAllObjects];
    }
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selected removeObjectForKey:indexPath];
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSDictionary *cellData = [self.dataSource objectAtIndex:indexPath.row];
        [self.selected setObject:cellData forKey:indexPath];
    }
}

- (IBAction)doneButtonTapped : (id) sender {
    NSMutableArray *selectedProfiles = [[self.selected allValues] mutableCopy];
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileSelected:)]) {
        //[self.delegate performSelector:@selector(profileSelected:) withObject:selectedProfiles];
        [self.delegate performSelectorOnMainThread:@selector(profileSelected:) withObject:selectedProfiles waitUntilDone:[NSThread isMainThread]];
    }
    [self cancelButtonTapped:nil];
}

@end
