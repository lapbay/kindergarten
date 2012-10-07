//
//  HJRecordViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/18/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJRecordViewController.h"
#import "IIViewDeckController.h"

#import "MIRequestManager+API.h"
#import "UIImageView+Web.h"
#import "HJProfilePickerViewController.h"
#import "UMSNSService.h"

@interface HJRecordViewController ()

@end

@implementation HJRecordViewController
@synthesize type = type;
@synthesize popoverController = _popoverController2;
@synthesize thumbnailView = _thumbnailView;
@synthesize textRecorder = _textRecorder;
@synthesize friendsView = _friendsView;
@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.type = HJRecordTypeFinish;
        self.recordData = [NSMutableDictionary dictionary];
        self.shouldAddCancelButton = NO;
    }
    return self;
}

-(void)setType:(HJRecordType)typ{
    type = typ;
    switch (typ) {
        case HJRecordTypeCheckin:
        {
            self.typeString = NSLocalizedString(@"签到", @"Checkin");
            break;
        }
        case HJRecordTypeRecord:
        {
            self.typeString = NSLocalizedString(@"纪录任务", @"Record");
            break;
        }
        case HJRecordTypeFinish:
        {
            self.typeString = NSLocalizedString(@"完成任务", @"Finish");
            break;
        }
        default:
            break;
    }
    self.title = self.typeString;
}

-(void)initDataSource:(NSArray *)source{
    if (source) {
        self.dataSource = source.mutableCopy;
        NSDictionary *data = [self.dataSource objectAtIndex:0];
        [self.taskSelectorButton setTitle:[data objectForKey:@"name"] forState: UIControlStateNormal];
        if (self.dataSource.count < 2) {
            self.taskSelectorButton.enabled = NO;
        }
        [self setGeo:nil];
    }else{
        [self queryTasksList:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle: self.typeString
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(recordTask:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    if (self.shouldAddCancelButton) {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", @"Cancel")
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(shouldDismiss:)];
        self.navigationItem.leftBarButtonItem = leftButton;
    }
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnMap:)];
    tap.numberOfTapsRequired = 1;
    [self.mapView addGestureRecognizer:tap];
    
    self.textRecorder.text = [NSString stringWithFormat:@"#在号角 %@#", self.typeString];
}

- (IBAction)shouldDismiss:(id)sender {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
    }
    [self dismissModalViewControllerAnimated:YES];
    self.viewDeckController.shouldFireViewMethods = YES;
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

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self.textRecorder resignFirstResponder];
	[[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self showCam:nil];
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)showCam:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        picker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.thumbnailView.image = nil;
    self.thumbnailView.image = image;
    //NSData *thumbnailData = UIImageJPEGRepresentation(image, 0.1);
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)recordTask:(id)sender {
    [self sendRecord];
}

- (IBAction)sendRecord {
    if (self.textRecorder.text.length == 0 && !self.thumbnailView.image) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请留言或拍照纪录"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    MIRequestManager *manager = [MIRequestManager requestManager];
    MIRequestFinishBlock finishBlock = ^(NSURLResponse *response, NSData *rData, NSError *error)
    {
        //NSLog(@"upload %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if ([rData length] > 0 && error == nil){
            NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
            NSInteger c = [[resp objectForKey:@"c"] intValue];
            if (c == 200) {
                @try {
//                    NSDictionary *d = [resp objectForKey:@"d"];
//                    NSLog(@"%@", d);
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (self.navigationController.viewControllers.count > 1) {
//                            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
//                        }else{
//                            [self.navigationController popToRootViewControllerAnimated:YES];
//                        }
                        [self dismissModalViewControllerAnimated:YES];
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
                NSString *message = [resp objectForKey:@"d"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert show];
                });
            }
        }
    };
    
    [self.recordData setObject:[NSString stringWithFormat:@"%d", self.type] forKey:@"type"];
    [self.recordData setObject:self.textRecorder.text forKey:@"desc"];
    [self.recordData setObject:self.taskId forKey:@"id"];
    if (self.superTaskId) {
        [self.recordData setObject:self.superTaskId forKey:@"super_task_id"];
    }
    
    NSMutableArray *friends = [NSMutableArray array];
    for (NSDictionary *friend in self.selectedFriends) {
        [friends addObject:[friend objectForKey:@"profile_id"]];
    }
    [self.recordData setObject:friends forKey:@"friends"];
    //Log(@"%@", self.recordData);
    
    if (self.thumbnailView.image) {
        UIImage *image  = self.thumbnailView.image;
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        NSString *imageMD5 = [MIRequestManager NSDataMD5HexDigest:imageData];
        [self.recordData setObject:imageMD5 forKey:@"md5"];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.%@", imageMD5, @"jpg"];
        NSString *mimeType = [MIRequestManager mimeTypeForExtension:@"jpg"];
        
        NSDictionary *file = [NSDictionary dictionaryWithObjectsAndKeys:fileName, @"fileName", mimeType, @"contentType", imageData, @"data", nil];
        NSMutableDictionary *files = [NSMutableDictionary dictionaryWithObjectsAndKeys:file, @"photo", nil];
        NSMutableDictionary *localParams = [NSDictionary dictionaryWithObjectsAndKeys:files, @"files", self.recordData, @"strings", nil];
        
        [manager fileUploader:localParams withFinishHandler:finishBlock withUploadHandler:^(NSURLConnection *connection, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite)
         {
             //NSLog(@"upload progress: %i, %i", totalBytesWritten, totalBytesExpectedToWrite);
         }];
    }else{
        [manager apiRecordTask:self.recordData withFinishHandler:finishBlock withErrorHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
             });
         }];
    }
}

- (IBAction)placeTapped:(id)sender {
    [self setGeo:sender];
}

- (void)handleTapOnMap:(id)sender {
}

- (NSDictionary *)setGeo:(id)sender {
//    CLLocationCoordinate2D coordinate;
//    coordinate.latitude = 39.9f;
//    coordinate.longitude = 116.4f;
//    MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
//    ann.coordinate = coordinate;
//    [ann setTitle:@"某地"];
//    [ann setSubtitle:@"Some place"];
//    [self.mapView addAnnotation:ann];
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1000.0f;
    [locationManager startUpdatingLocation];
    CLLocationCoordinate2D coordinate = [[locationManager location] coordinate];
    
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.05;
    theSpan.longitudeDelta = 0.05;
    MKCoordinateRegion theRegion;
    theRegion.center = coordinate;
    theRegion.span = theSpan;
    [self.mapView setRegion:theRegion];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%f", coordinate.longitude], @"longitude", [NSString stringWithFormat:@"%f", coordinate.latitude], @"latitude", nil];
    [self.recordData addEntriesFromDictionary:params];
    return params;
}

- (void)queryTasksList:(id) sender{
    NSMutableDictionary *params = [[self setGeo:nil] mutableCopy];
    [params setObject:@"self" forKey:@"id"];
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiUserTasks:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
     {
         if ([rData length] > 0 && error == nil){
             //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
             NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
             NSInteger c = [[resp objectForKey:@"c"] intValue];
             if (c == 200) {
                 @try {
                     NSArray *d = [resp objectForKey:@"d"];
                     self.dataSource = [NSMutableArray arrayWithArray:d];
                     Log(@"%@", self.dataSource);
                     NSDictionary *data = [self.dataSource objectAtIndex:0];
                     self.taskId = [data objectForKey:@"task_id"];
                     if ([data objectForKey:@"super_task_id"]) {
                         self.superTaskId = [data objectForKey:@"super_task_id"];
                     }else{
                         self.superTaskId = nil;
                     }

                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.taskSelectorButton setTitle:[data objectForKey:@"name"] forState: UIControlStateNormal];
                         if (self.dataSource.count < 2) {
                             self.taskSelectorButton.enabled = NO;
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
     } withErrorHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
         });
     }];
}

- (IBAction)socialShare:(id) sender {
//    [UMSNSService showSNSActionSheetInController:self appkey:UMENG_KEY status:@"sdfsdfsdfsd" image:nil];
    [UMSNSService presentSNSInController:self appkey:UMENG_KEY status:self.textRecorder.text image:nil platform:UMShareToTypeSina];
}

- (IBAction)withTapped:(id) sender {
    HJProfilePickerViewController *pPicker = [[HJProfilePickerViewController alloc] initWithNibName:@"HJProfilePickerViewController" bundle:nil];
    pPicker.delegate = self;
    [self.navigationController pushViewController:pPicker animated:YES];
}

- (void)profileSelected:(NSArray *)selectedProfiles {
    self.selectedFriends = selectedProfiles.mutableCopy;
    for (int i = 0; i < self.selectedFriends.count; i++) {
        //NSDictionary *profile = [self.selectedFriends objectAtIndex:i];
        UIImageView *avatar = [self.friendsView.subviews objectAtIndex:0];
        [avatar loadWebImage:@"http://www.baidu.com/img/baidu_sylogo1.gif" withIndex:[NSString stringWithFormat:@"%i", i]];
    }
}

- (IBAction)taskSelectorTapped:(id) sender{
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择一个任务"
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
}

-(IBAction)dismissActionSheetWithSave:(id) sender {
    NSInteger selectedIndex = [self.dataPicker selectedRowInComponent:0];
    NSDictionary *data = [self.dataSource objectAtIndex:selectedIndex];
    [self.taskSelectorButton setTitle:[data objectForKey:@"name"] forState: UIControlStateNormal];
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(IBAction)dismissActionSheetWithCancel:(id) sender {
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger result = self.dataSource.count;
    return result;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *result = [[self.dataSource objectAtIndex:row] objectForKey:@"name"];
    return result;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDictionary *data = [self.dataSource objectAtIndex:row];
    self.taskId = [data objectForKey:@"task_id"];
    if ([data objectForKey:@"super_task_id"]) {
        self.superTaskId = [data objectForKey:@"super_task_id"];
    }else{
        self.superTaskId = nil;
    }
}

@end
