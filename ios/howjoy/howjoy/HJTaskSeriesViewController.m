//
//  HJTaskSeriesViewController.m
//  howjoy
//
//  Created by Wu Chang on 9/13/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJTaskSeriesViewController.h"
#import "MIRequestManager+API.h"
#import "HJProfileViewController.h"
#import "HJRecordViewController.h"
#import "HJProfilePickerViewController.h"
#import "UMSNSService.h"
#import "HJCreateTaskViewController.h"
#import "HJTaskViewController.h"
#import "HJEditViewController.h"

@interface HJTaskSeriesViewController () {
}
@end

@implementation HJTaskSeriesViewController
@synthesize type = type;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"系列任务", @"Task Series");
        self.dataInitialized = NO;
        self.allData = @{}.mutableCopy;
        self.pickerData = @{@"categories":@[@"a", @"b", @"c"], @"max": @"100", @"points": @"200"};
        
        self.dataTitles = @{@"name":@"标题", @"desc":@"描述", @"deadline":@"截止", @"max":@"最多", @"points":@"积分", @"bonus":@"奖励", @"start_at":@"开始", @"place":@"地点", @"categories":@"分类", @"tags":@"标签", @"subtasks": @"子任务"};
        NSDictionary *d = @{@"name":@"", @"desc":@"", @"deadline":@"", @"max":@"", @"points":@"", @"bonus":@"", @"start_at":@"", @"categories":@"", @"tags":@"", @"subtasks": @[].mutableCopy};
        self.dataSource = d.mutableCopy;
        self.dataKeys = @[@[@"name", @"desc", @"categories", @"tags", @"bonus"], @[@"deadline", @"start_at"], @[@"max", @"points"], @[@"Add subtasks"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.allowsSelectionDuringEditing = YES;
    [self resetRightButton];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

-(void)resetRightButton{
    self.navigationItem.rightBarButtonItem = nil;
    if (self.type == HJTaskTypeSeriesCreate) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
        self.navigationItem.rightBarButtonItems = @[doneButton, self.editButtonItem];
    }else if (self.type == HJTaskTypeSeriesModify || self.type == HJTaskTypeView) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(barButtonTapped:)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }else{
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.taskId && !self.dataInitialized) {
        NSDictionary *params = @{@"type": @"0", @"id": self.taskId};
        MIRequestManager *manager = [MIRequestManager requestManager];
        [manager apiTaskInfo:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
         {
             if ([rData length] > 0 && error == nil){
                 //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
                 NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
                 NSInteger c = [[resp objectForKey:@"c"] intValue];
                 if (c == 200) {
                     @try {
                         self.dataInitialized = YES;
                         self.dataSaved = YES;
                         NSMutableDictionary *d = [resp objectForKey:@"d"];
                         self.allData = d;
                         self.taskId = [d objectForKey:@"id"];

                         NSMutableDictionary *task =[d objectForKey:@"task"];
                         self.dataSource = task;
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if ([self.allData objectForKey:@"role"] && [[self.allData objectForKey:@"role"] intValue] == 10) {
                                 self.type = HJTaskTypeSeriesModify;
                                 [self resetRightButton];
                             }
                             [self.tableView reloadData];
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
}

- (void)barButtonTapped:(id)sender {
    if (self.type == HJTaskTypeSeriesCreate) {
        
    }else if (self.type == HJTaskTypeSeriesModify || self.type == HJTaskTypeView) {
        UIActionSheet *select;
        if ([self.allData objectForKey:@"role"] && [[self.allData objectForKey:@"role"] intValue] == 10) {
            if(self.dataSaved) {
                select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"关闭任务" otherButtonTitles:@"编辑", @"邀请好友", @"分享", nil];
            }else{
                select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"关闭任务" otherButtonTitles:@"编辑", @"保存", @"邀请好友", @"分享", nil];
            }
        }else{
            int status = [[self.allData objectForKey:@"status"] intValue];
            Log(@"%i", status);
            switch (status) {
                case 0:
                {
                    select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"加入", @"邀请好友", @"分享", nil];
                    break;
                }
                case 1:
                case 2:
                {
                    select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"邀请好友", @"分享", nil];
                    break;
                }
                default:
                    select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"邀请好友", nil];
                    break;
            }
        }
        [select showFromBarButtonItem:sender animated:YES];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"%i", buttonIndex);
    }else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认"
                                                        message:@"确定要关闭这个任务吗?"
                                                       delegate:self
                                              cancelButtonTitle:@"不关闭"
                                              otherButtonTitles:@"关闭", nil];
        alert.tag = 100;
        [alert show];
    }else {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSMutableDictionary *task =[self.allData objectForKey:@"task"];
        if ([title isEqualToString:@"邀请好友"]) {
            HJProfilePickerViewController *viewController5 = [[HJProfilePickerViewController alloc] initWithNibName:@"HJProfilePickerViewController" bundle:nil];
            viewController5.delegate = self;
            [self.navigationController pushViewController:viewController5 animated:YES];
        }else if ([title isEqualToString:@"分享"]) {
            [UMSNSService presentSNSInController:self appkey:UMENG_KEY status:@"test umeng sina share" image:nil platform:UMShareToTypeSina];
        }else if ([title isEqualToString:@"完成"]) {
            HJRecordViewController *viewController5 = [[HJRecordViewController alloc] initWithNibName:@"HJRecordViewController" bundle:nil];
            viewController5.type = HJRecordTypeFinish;
            [self.navigationController pushViewController:viewController5 animated:YES];
            [viewController5 initDataSource:@[task]];
        }else if ([title isEqualToString:@"加入"]) {
            [self joinButtonTapped:nil];
        }else if ([title isEqualToString:@"保存"]) {
            [self doneButtonTapped:nil];
        }else if ([title isEqualToString:@"编辑"]) {
            NSLog(@"%@", @"should Modify");
            self.allowToShowEditors = !self.allowToShowEditors;
            self.dataSaved = NO;
            if (self.isEditing) {
                [self setEditing:NO animated:YES];
            }else{
                [self setEditing:YES animated:YES];
            }
            [self.tableView reloadData];
//            NSDictionary *source = @{@"id": self.taskId, @"name":self.titleValueLabel.text, @"desc":self.descValueTextView.text, @"deadline":self.deadlineValueLabel.text, @"max":self.maxValueLabel.text, @"points":self.maxValueLabel.text, @"bonus":self.maxValueLabel.text, @"start_at":self.startatValueLabel.text, @"place":self.locationValueLabel.text, @"categories":self.categoriesValueLabel.text, @"tags":@""};
//            HJCreateTaskViewController *creator = [[HJCreateTaskViewController alloc] initWithNibName:@"HJCreateTaskViewController" bundle:nil];
//            creator.type = HJCreateTaskTypeIndependentModify;
//            [creator reloadWithDataSource:source andDelegate:self];
//            [self.navigationController pushViewController:creator animated:YES];
        }
    }
}

- (IBAction)cancelButtonTapped : (id) sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doneButtonTapped : (id) sender {
    BOOL ok = YES;
    for (NSString *key in self.dataSource) {
        id value = [self.dataSource objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            if (((NSArray *) value).count == 0) {
                ok = NO;
                break;
            }
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            if (((NSDictionary *) value).count == 0) {
                ok = NO;
                break;
            }
        }else if ([value isKindOfClass:[NSNumber class]]) {
            break;
        }else if ([value isKindOfClass:[NSString class]]) {
            if (((NSString *) value).length == 0) {
                ok = NO;
                break;
            }
        }
    }
    if (ok) {
        MIRequestFinishBlock finishBlock = ^(NSURLResponse *response, NSData *rData, NSError *error)
        {
            
            if ([rData length] > 0 && error == nil){
                //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
                NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
                NSInteger c = [[resp objectForKey:@"c"] intValue];
                if (c == 200) {
                    @try {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.dataSaved = YES;
                            [self dismissModalViewControllerAnimated:YES];
                            if (self.navigationController.viewControllers.count > 1) {
                                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
                            }
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
        };
        MIRequestFinishBlock errorBlock = ^(NSURLResponse *response, NSData *data, NSError *error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        };
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.dataSource];
        [params setObject:@"series" forKey:@"type"];
        if (self.taskId) {
            [params setObject:self.taskId forKey:@"id"];
        }
        NSLog(@"%@", params);

        MIRequestManager *manager = [MIRequestManager requestManager];
        if (self.type == HJTaskTypeSeriesModify) {
            //[self dismissModalViewControllerAnimated:YES];
            [manager apiTaskUpdate:params withFinishHandler:finishBlock withErrorHandler:errorBlock];
        }else if (self.type == HJTaskTypeSeriesCreate) {
            [manager apiTaskCreate:params withFinishHandler:finishBlock withErrorHandler:errorBlock];
        }else{
            Log(@"%@", @"Invalid type");
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入所有必填项"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (void)insertNewObject:(id)sender
//{
//    NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];
//    [subtasks insertObject:[[NSDate date] description] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == self.dataKeys.count - 1) {
        NSArray *subs = [self.dataSource objectForKey:@"subtasks"];
        rows = subs.count + 1;
        if(self.type == HJTaskTypeSeriesCreate || self.isEditing) {
            rows = subs.count + 1;
        }else{
            rows = subs.count;
        }
    }else{
        NSArray *subs = [self.dataKeys objectAtIndex:section];
        rows = subs.count;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *res;
    if (section == self.dataKeys.count - 1) {
        res = @"子任务";
    }
    return res;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 44.0f;
    if (indexPath.section == 0) {
        if ([self.dataKeys objectAtIndex:indexPath.section]) {
            NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            NSString *value;
            if ([[self.dataSource objectForKey:key] isKindOfClass:[NSString class]]) {
                value = [self.dataSource objectForKey:key];
            }else if ([[self.dataSource objectForKey:key] isKindOfClass:[NSString class]]) {
                NSArray *arr = [self.dataSource objectForKey:key];
                value = [arr componentsJoinedByString:@" "];
            }
            UIFont *font = [UIFont systemFontOfSize:15.0];
            
            CGSize size = [value sizeWithFont:font constrainedToSize:CGSizeMake(230, 1000) lineBreakMode:UILineBreakModeWordWrap];
            height = size.height + 10;
        }else{
            height = 96.0f;
        }
    }
    return MAX(height, 44.0f);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HJTaskSeriesViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    }
    if (indexPath.section == 0) {
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    }

    if (indexPath.section == self.dataKeys.count - 1) {
        NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];
        if (indexPath.row >= subtasks.count) {
            cell.textLabel.text = @"+ 添加子任务";
            cell.detailTextLabel.text = nil;
        }else{
            NSDictionary *value = [subtasks objectAtIndex:indexPath.row];
            cell.textLabel.text = [value objectForKey:@"name"];
            cell.detailTextLabel.text = [value objectForKey:@"desc"];
        }
    }else{
        NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [self.dataTitles objectForKey:key];
        id value = [self.dataSource objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            cell.detailTextLabel.text = value;
        }else if ([value isKindOfClass:[NSNumber class]]) {
            cell.detailTextLabel.text = [value stringValue];
        }else if ([value isKindOfClass:[NSArray class]]) {
            cell.detailTextLabel.text = [value componentsJoinedByString:@" "];
        }else{
            cell.detailTextLabel.text = value;
        }
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL res = NO;
    NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];
    
    if (indexPath.section == self.dataKeys.count - 1 && indexPath.row != subtasks.count && subtasks.count >= 1) {
        res = YES;
    }
    return res;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    [super setEditing:editing animated:animate];
    if(editing)
    {
        NSLog(@"editMode on");
    }
    else
    {
        NSLog(@"Done leave editmode");
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];

        [subtasks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];
    if (sourceIndexPath.section != proposedDestinationIndexPath.section || proposedDestinationIndexPath.row == subtasks.count) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];
    if (fromIndexPath != toIndexPath && toIndexPath.section == self.dataKeys.count - 1 && toIndexPath.row != subtasks.count) {
        NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];

        NSDictionary *task1 = [subtasks objectAtIndex:fromIndexPath.row];
        [subtasks removeObjectAtIndex:fromIndexPath.row];
        if (toIndexPath.row > subtasks.count) {
            [subtasks addObject:task1];
        }
        else {
            [subtasks insertObject:task1 atIndex:toIndexPath.row];
        }
        [self.dataSource setObject:subtasks forKey:@"subtasks"];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL res = NO;
    NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];

    if (indexPath.section == self.dataKeys.count - 1 && indexPath.row != subtasks.count && subtasks.count > 0) {
        res = YES;
    }
    return res;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.allowToShowEditors == YES) {
        self.indexPathEditing = indexPath;
        if (indexPath.section == self.dataKeys.count - 1) {
            HJCreateTaskViewController *creator = [[HJCreateTaskViewController alloc] initWithNibName:@"HJCreateTaskViewController" bundle:nil];
            creator.delegate = self;

            NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];
            NSDictionary *data;
            if (indexPath.row == subtasks.count) {
                //            [subtasks insertObject:@{@"name": [[NSDate date] description]} atIndex:0];
                //            [self.dataSource setObject:subtasks forKey:@"subtasks"];
                //            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                data = @{@"name":@"", @"desc":@"", @"deadline":@"", @"max":@"", @"points":@"", @"bonus":@"", @"start_at":@"", @"place":@"", @"categories":@"", @"tags":@""};
                creator.type = HJTaskTypeSeriesCreate;
            }else{
                data = [subtasks objectAtIndex:indexPath.row];
                creator.type = HJTaskTypeSeriesModify;
            }
            [self.navigationController pushViewController:creator animated:YES];
            [creator reloadWithDataSource:data andDelegate:self];
        }else{
            NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            switch (indexPath.section) {
                case 0:
                {
                    id value = [self.dataSource objectForKey:key];
                    NSString *text;
                    if ([value isKindOfClass:[NSString class]]) {
                        text = value;
                    }else if ([value isKindOfClass:[NSNumber class]]) {
                        text = [value stringValue];
                    }else if ([value isKindOfClass:[NSArray class]]) {
                        text = [value componentsJoinedByString:@" "];
                    }
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入"
//                                                                    message:[NSString stringWithFormat:@"输入 %@ 的值", [self.dataTitles objectForKey:key]]
//                                                                   delegate:self
//                                                          cancelButtonTitle:@"Cancel"
//                                                          otherButtonTitles:@"Save", nil];
//                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//                    [[alert textFieldAtIndex:0] setText:text];
//                    [alert show];
                    HJEditViewController *editer = [[HJEditViewController alloc] initWithNibName:@"HJEditViewController" bundle:nil];
                    editer.type = 0;
                    editer.delegate = self;
                    [self.navigationController pushViewController:editer animated:YES];
                    editer.editView.text = text;
                    break;
                }
                case 1:
                {
                    self.actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"选择 %@ 的值", [self.dataTitles objectForKey:key]]
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:nil];
                    
                    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                    
                    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
                    self.datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
                    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                    self.datePicker.minuteInterval = 30;
                    
                    NSString *value = [self.dataSource objectForKey:key];
                    
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    [dateFormat setDateFormat:@"yyyy-MM-dd|HH:mm"];
                    NSDate *parsed = [dateFormat dateFromString:value];
                    if (value && parsed) {
                        [self.datePicker setDate:parsed animated:YES];
                    }
                    
                    [self.actionSheet addSubview:self.datePicker];
                    
                    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"关闭"]];
                    closeButton.momentary = YES;
                    closeButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
                    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
                    closeButton.tintColor = [UIColor blackColor];
                    [closeButton addTarget:self action:@selector(dismissActionSheetWithCancel:) forControlEvents:UIControlEventValueChanged];
                    [self.actionSheet addSubview:closeButton];
                    
                    UISegmentedControl *saveButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"保存"]];
                    saveButton.momentary = YES;
                    saveButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
                    saveButton.segmentedControlStyle = UISegmentedControlStyleBar;
                    saveButton.tintColor = [UIColor blueColor];
                    [saveButton addTarget:self action:@selector(dismissActionSheetWithSave:) forControlEvents:UIControlEventValueChanged];
                    [self.actionSheet addSubview:saveButton];
                    
                    [self.actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
                    
                    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
                    break;
                }
                case 2:
                {
                    self.actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"选择 %@ 的值", [self.dataTitles objectForKey:key]]
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:nil];
                    
                    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                    
                    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
                    self.dataPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
                    self.dataPicker.showsSelectionIndicator = YES;
                    self.dataPicker.dataSource = self;
                    self.dataPicker.delegate = self;
                    //NSString *value = [self.dataSource objectForKey:key];
                    
                    [self.actionSheet addSubview:self.dataPicker];
                    
                    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"关闭"]];
                    closeButton.momentary = YES;
                    closeButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
                    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
                    closeButton.tintColor = [UIColor blackColor];
                    [closeButton addTarget:self action:@selector(dismissActionSheetWithCancel:) forControlEvents:UIControlEventValueChanged];
                    [self.actionSheet addSubview:closeButton];
                    
                    UISegmentedControl *saveButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"保存"]];
                    saveButton.momentary = YES;
                    saveButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
                    saveButton.segmentedControlStyle = UISegmentedControlStyleBar;
                    saveButton.tintColor = [UIColor blueColor];
                    [saveButton addTarget:self action:@selector(dismissActionSheetWithSave:) forControlEvents:UIControlEventValueChanged];
                    [self.actionSheet addSubview:saveButton];
                    
                    [self.actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
                    
                    [self.actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
                    break;
                }
                default:
                    break;
            }
        }
    }else{
        if (indexPath.section == self.dataKeys.count - 1) {
            NSMutableArray *subtasks = [self.dataSource objectForKey:@"subtasks"];
            NSDictionary *data;
            if (indexPath.row == subtasks.count) {
                //            [subtasks insertObject:@{@"name": [[NSDate date] description]} atIndex:0];
                //            [self.dataSource setObject:subtasks forKey:@"subtasks"];
                //            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                //data = @{@"name":@"", @"desc":@"", @"deadline":@"", @"max":@"", @"points":@"", @"bonus":@"", @"start_at":@"", @"place":@"", @"categories":@"", @"tags":@""};
            }else{
                data = [subtasks objectAtIndex:indexPath.row];
                HJTaskViewController *task = [[HJTaskViewController alloc] initWithNibName:@"HJTaskViewController" bundle:nil];
                task.superTaskId = self.taskId;
                if ([data objectForKey:@"id"]) {
                    task.taskId = [data objectForKey:@"id"];
                }else{
                    NSString *status;
                    if ([data objectForKey:@"id"]) {
                        status = [[data objectForKey:@"id"] stringValue];
                    }else{
                        status = [[self.allData objectForKey:@"status"] stringValue];
                    }
                    task.allData = @{@"task": data, @"role": [self.allData objectForKey:@"role"], @"status": status}.mutableCopy;
                }
                [self.navigationController pushViewController:task animated:YES];
            }
        }else{
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag != 100) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] <= 0 || buttonIndex == 0){
            return;
        }
        if (buttonIndex == 1) {
            NSIndexPath *indexPath = self.indexPathEditing;
            NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [self.dataSource setObject:textField.text forKey:key];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        [self.tableView reloadData];
    }else{
        if (buttonIndex == 1) {
            NSLog(@"%@", @"should close the task");
        }
    }
}

-(IBAction)textEditDidFinished:(NSString *) txt {
    NSIndexPath *indexPath = self.indexPathEditing;
    NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.dataSource setObject:txt forKey:key];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
}

-(IBAction)dismissActionSheetWithSave:(id) sender {
    NSIndexPath *indexPath = self.indexPathEditing;
    switch (indexPath.section) {
        case 1:
        {
            //Log(@"%@", self.datePicker.date);
            NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
            [yearFormat setDateFormat:@"yyyy-MM-dd|HH:mm"];
            NSString *dateString = [yearFormat stringFromDate:self.datePicker.date];
            [self.dataSource setObject:dateString forKey:key];
            [self.tableView reloadData];
            break;
        }
        case 2:
        {
            NSString *result;
            NSInteger row = [self.dataPicker selectedRowInComponent:0];
            NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            if ([key isEqualToString:@"categories"]) {
                NSArray *categories = [self.pickerData objectForKey:@"categories"];
                result = [categories objectAtIndex:row];
            }else if ([key isEqualToString:@"max"]) {
                result = [NSString stringWithFormat:@"%i", row + 1];
            }else if ([key isEqualToString:@"points"]) {
                result = [NSString stringWithFormat:@"%i", row + 1];
            }
            
            [self.dataSource setObject:result forKey:key];
            [self.tableView reloadData];
            break;
        }
        default:
            break;
    }
    
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(IBAction)dismissActionSheetWithCancel:(id) sender {
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger result;
    NSIndexPath *indexPath = self.indexPathEditing;
    NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"categories"]) {
        NSArray *categories = [self.pickerData objectForKey:@"categories"];
        result = categories.count;
    }else if ([key isEqualToString:@"max"]) {
        NSString *max = [self.pickerData objectForKey:@"max"];
        result = [max integerValue];
    }else if ([key isEqualToString:@"points"]) {
        NSString *points = [self.pickerData objectForKey:@"points"];
        result = [points integerValue];
    }
    return result;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *result;
    NSIndexPath *indexPath = self.indexPathEditing;
    NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"categories"]) {
        NSArray *categories = [self.pickerData objectForKey:@"categories"];
        result = [categories objectAtIndex:row];
    }else if ([key isEqualToString:@"max"]) {
        result = [NSString stringWithFormat:@"%i", row + 1];
    }else if ([key isEqualToString:@"points"]) {
        result = [NSString stringWithFormat:@"%i", row + 1];
    }
    return result;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
}


- (void)profileSelected:(NSArray *)selectedProfiles {
    Log(@"profileSelected %@", selectedProfiles);
    NSMutableArray *profiles = [NSMutableArray array];
    for (NSDictionary *profile in selectedProfiles) {
        [profiles addObject:[profile objectForKey:@"profile_id"]];
    }
    NSDictionary *params = @{@"act": @"invite", @"task_id": self.taskId, @"task_type": @"1", @"profiles": profiles};
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiInviteFriends:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
         });
         
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
//                     NSDictionary *d = [resp objectForKey:@"d"];
//                     NSLog(@"%@", d);
//                     
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                     });
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

- (void)didModifyTask:(NSDictionary *)task{
    NSMutableDictionary *tTask = task.mutableCopy;
    if (![task objectForKey:@"type"]) {
        [tTask setObject:@"2" forKey:@"type"];
    }
    
    NSIndexPath *indexPath = self.indexPathEditing;

    NSMutableArray *subtasks = [[self.dataSource objectForKey:@"subtasks"] mutableCopy];
    
    if (indexPath.section == self.dataKeys.count - 1) {
        if (indexPath.row == subtasks.count) {
            [subtasks addObject:tTask];
            //[subtasks insertObject:task atIndex:0];
            //[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [subtasks replaceObjectAtIndex:indexPath.row withObject:tTask];
        }
        [self.dataSource setObject:subtasks forKey:@"subtasks"];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
    }
}


- (void)joinButtonTapped:(id)sender {
    NSDictionary *params = @{@"id": self.taskId, @"desc": @"desc sdfsdfsdfsdfsdf_supdated"};
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiJoinTask:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
         });
         
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
//                     NSDictionary *d = [resp objectForKey:@"d"];
//                     NSLog(@"%@", d);
//                     
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                     });
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
