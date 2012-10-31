//
//  HJCreateTaskViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/13/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJCreateTaskViewController.h"
#import "MIRequestManager+API.h"
#import "HJEditViewController.h"
#import "HJProfilePickerViewController.h"

@interface HJCreateTaskViewController ()

@end

@implementation HJCreateTaskViewController
@synthesize contentView = _contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"发布新任务", @"Create Task");
        self.type = HJTaskTypeIndependentCreate;
        self.pickerData = @{@"categories":@[@"a", @"b", @"c"]};
        NSDictionary *d = @{@"name":@"", @"desc":@"", @"deadline":@"", @"bonus":@"", @"actor":@"actor", @"start_at":@"", @"place":@"", @"categories":@""};
        self.dataSource = d.mutableCopy;
        self.dataTitles = @{@"name":@"标题", @"desc":@"描述", @"deadline":@"截止", @"bonus":@"奖励", @"actor":@"执行人", @"start_at":@"开始", @"place":@"地点", @"categories":@"分类"};
        self.dataKeys = @[@[@"name", @"desc"], @[@"deadline", @"start_at", @"place"], @[@"categories", @"actor"], @[@"bonus"]];
        d = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = NavButton;
    
    self.contentView.delegate = self;
    self.contentView.dataSource = self;
    if (self.type == HJTaskTypeIndependentModify || self.type == HJTaskTypeSeriesModify) {
        self.title = NSLocalizedString(@"编辑任务", @"Modify Task");
    }else if (self.type == HJTaskTypeSeriesCreate) {
        self.title = NSLocalizedString(@"新建子任务", @"Create Subtask");
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
}

- (void)reloadWithDataSource:(NSDictionary *)source andDataKeys:(NSArray *)keys andDelegate: (id) dele {
    self.delegate = dele;
    self.dataSource = source.mutableCopy;
    self.dataKeys = keys;
    [self.contentView reloadData];
}

- (void)reloadWithDataSource:(NSDictionary *)source andDelegate: (id) dele {
    self.delegate = dele;
    self.dataSource = source.mutableCopy;
    [self.contentView reloadData];
}

// Customize the number of rows in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataKeys.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataKeys objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 44.0f;
    if (indexPath.section == 0) {
        if ([self.dataKeys objectAtIndex:indexPath.section]) {
            NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            NSString *value = [self.dataSource objectForKey:key];
            UIFont *font = [UIFont systemFontOfSize:15.0];
            CGSize size = [value sizeWithFont:font constrainedToSize:CGSizeMake(230, 1000) lineBreakMode:UILineBreakModeWordWrap];
            height = size.height + 10;
        }else{
            height = 96.0f;
        }
    }
    return MAX(height, 44.0f);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"HJCreateTaskCellDefault";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    }
    
//    HJTaskCell *cell = (HJTaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HJTaskCell" owner:nil options:nil];
//        for(id currentObject in topLevelObjects) {
//            if([currentObject isKindOfClass:[HJTaskCell class]]) {
//                cell = (HJTaskCell *) currentObject;
//                break;
//            }
//        }
//        //cell.contentView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:240.0f/255.0f blue:1.0f alpha:1.0f];
//        //cell.titleLabel.backgroundColor = [UIColor clearColor];
//    }
    if (indexPath.section == 0) {
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    }
    
    NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    cell.textLabel.text = [self.dataTitles objectForKey:key];
    id value = [self.dataSource objectForKey:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        cell.detailTextLabel.text = [value stringValue];
    }else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
        cell.detailTextLabel.text = [value JSONRepresentation];
    }else{
        cell.detailTextLabel.text = value;
    }
    
    cell.imageView.image = [UIImage imageNamed:@"must"];
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexPathEditing = indexPath;
    NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    switch (indexPath.section) {
        case 0:
        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入"
//                                                            message:[NSString stringWithFormat:@"输入 %@ 的值", [self.dataTitles objectForKey:key]]
//                                                           delegate:self
//                                                  cancelButtonTitle:@"取消"
//                                                  otherButtonTitles:@"确定", nil];
//            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//            [[alert textFieldAtIndex:0] setText:[self.dataSource objectForKey:key]];
//            [alert show];
            HJEditViewController *editer = [[HJEditViewController alloc] initWithNibName:@"HJEditViewController" bundle:nil];
            editer.type = 0;
            editer.delegate = self;
            [self.navigationController pushViewController:editer animated:YES];
            editer.editView.text = [self.dataSource objectForKey:key];
            break;
        }
        case 1:
        {
            if (indexPath.row != 2) {
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
            }else{
                HJMapViewController *map = [[HJMapViewController alloc] initWithNibName:@"HJMapViewController" bundle:nil];
                map.delegate = self;
                map.maxPins = 1;
                [self.navigationController pushViewController:map animated:YES];
            }
            break;
        }
        case 2:
        {
            switch (indexPath.row) {
                case 0:
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
                case 1:
                {
                    HJProfilePickerViewController *pPicker = [[HJProfilePickerViewController alloc] initWithNibName:@"HJProfilePickerViewController" bundle:nil];
                    pPicker.delegate = self;
                    [self.navigationController pushViewController:pPicker animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 3:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入"
                                                            message:[NSString stringWithFormat:@"输入 %@ 的值", [self.dataTitles objectForKey:key]]
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Save", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [[alert textFieldAtIndex:0] setText:[self.dataSource objectForKey:key]];
            [alert show];
            break;
        }
        default:
            break;
    }

}

- (IBAction)withTapped:(id) sender {
}

- (void)profileSelected:(NSArray *)selectedProfiles {
    self.selectedProfiles = selectedProfiles.mutableCopy;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField *textField = [alertView textFieldAtIndex:0];
    if ([textField.text length] <= 0 || buttonIndex == 0){
        return;
    }
    if (buttonIndex == 1) {
        NSIndexPath *indexPath = [self.contentView indexPathForSelectedRow];
        NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [self.dataSource setObject:textField.text forKey:key];
        [self.contentView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [self.contentView reloadData];
}

-(IBAction)textEditDidFinished:(NSString *) txt {
    NSIndexPath *indexPath = self.indexPathEditing;
    NSString *key = [[self.dataKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.dataSource setObject:txt forKey:key];
    [self.contentView deselectRowAtIndexPath:indexPath animated:YES];
    [self.contentView reloadData];
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
            [self.contentView reloadData];
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
            [self.contentView reloadData];
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

- (void)didDropPinAt:(NSArray *) coordinate {
    [self.dataSource setObject:[NSString stringWithFormat:@"%@, %@", [coordinate objectAtIndex:0], [coordinate objectAtIndex:1]] forKey:@"place"];
    [self.contentView reloadData];
}

- (IBAction)doneButtonTapped : (id) sender {
    BOOL ok = YES;
    for (NSString *key in self.dataSource) {
        id value = [self.dataSource objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            if (((NSArray *) value).count == 0) {
                ok = NO;
                Log(@"%@", key);
                break;
            }
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            if (((NSDictionary *) value).count == 0) {
                ok = NO;
                Log(@"%@", key);
                break;
            }
        }else if ([value isKindOfClass:[NSNumber class]]) {
            break;
        }else if ([value isKindOfClass:[NSString class]]) {
            if (((NSString *) value).length == 0) {
                ok = NO;
                Log(@"%@", key);
                break;
            }
        }
    }
    if (ok) {
//        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//        locationManager.delegate = self;
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        locationManager.distanceFilter = 1000.0f;
//        [locationManager startUpdatingLocation];
//        CLLocationCoordinate2D coordinate = [[locationManager location] coordinate];
//        
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        [params setObject:[NSString stringWithFormat:@"%f", coordinate.longitude] forKey:@"longitude"];
//        [params setObject:[NSString stringWithFormat:@"%f", coordinate.latitude] forKey:@"latitude"];
//        [params addEntriesFromDictionary:self.dataSource];
        MIRequestFinishBlock finishBlock = ^(NSURLResponse *response, NSData *rData, NSError *error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            });
            
            if ([rData length] > 0 && error == nil){
                //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
                NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
                NSInteger c = [[resp objectForKey:@"c"] intValue];
                if (c == 200) {
                    @try {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.type == HJTaskTypeIndependentModify || self.type == HJTaskTypeSeriesModify) {
                                if (self.delegate && [self.delegate respondsToSelector:@selector(didModifyTask:)]) {
                                    [self.delegate performSelector:@selector(didModifyTask:) withObject:self.dataSource];
                                }
                            }
                            if (self.navigationController.viewControllers.count > 1) {
                                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
                            }else{
                                [self.navigationController popToRootViewControllerAnimated:YES];
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
        MIRequestManager *manager = [MIRequestManager requestManager];
        Log(@"%i", self.type);

        if (self.type == HJTaskTypeSeriesModify || self.type == HJTaskTypeSeriesCreate) {
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(didModifyTask:)]) {
                [self.delegate performSelector:@selector(didModifyTask:) withObject:self.dataSource];
            }
        }else if (self.type == HJTaskTypeIndependentModify) {
            [manager apiTaskUpdate:self.dataSource withFinishHandler:finishBlock withErrorHandler:errorBlock];
        }else if (self.type == HJTaskTypeIndependentCreate) {
            [manager apiTaskCreate:self.dataSource withFinishHandler:finishBlock withErrorHandler:errorBlock];
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

@end
