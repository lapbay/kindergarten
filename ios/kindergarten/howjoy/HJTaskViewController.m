//
//  HJTaskViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HJTaskViewController.h"
#import "MIRequestManager+API.h"
#import "UIImageView+Web.h"
#import "HJMapViewController.h"
#import "HJProfileViewController.h"
#import "HJRecordViewController.h"
#import "HJProfilePickerViewController.h"
#import "UMSNSService.h"
#import "HJCreateTaskViewController.h"
#import "HJPropsViewController.h"

@interface HJTaskViewController ()

@end

@implementation HJTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"任务", @"Task");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
	
- (id)initWithNibName:(NSString *)nibNameOrNil id:(NSString *)tid
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"任务", @"Task");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.taskId = tid;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLocation:)];
    tap.numberOfTapsRequired = 1;
    [self.locationValueLabel addGestureRecognizer:tap];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnOrganizer:)];
    tap1.numberOfTapsRequired = 1;
    [self.organizerValueLabel addGestureRecognizer:tap1];

    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(barButtonTapped:)];
    self.navigationItem.rightBarButtonItem = NavButton;

    if (self.taskId) {
        NSMutableDictionary *params = @{@"type": @"0", @"id": self.taskId}.mutableCopy;
        MIRequestManager *manager = [MIRequestManager requestManager];
        [manager apiTaskInfo:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
         {
             if ([rData length] > 0 && error == nil){
                 //NSLog(@"%@", [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding]);
                 NSMutableDictionary *resp = [NSMutableDictionary dictionaryWithDictionary:[rData JSONValue]];
                 NSInteger c = [[resp objectForKey:@"c"] intValue];
                 if (c == 200) {
                     @try {
                         NSMutableDictionary *d = [resp objectForKey:@"d"];
                         NSLog(@"%@", d);

                         self.allData = d;
                         NSMutableDictionary *task =[self.allData objectForKey:@"task"];
                         NSMutableArray *other =[task objectForKey:@"other"];
                         
                         self.taskId = [d objectForKey:@"id"];
                         self.otherSource = [NSMutableArray arrayWithArray:other];
                         NSInteger type = [[[self.allData objectForKey:@"task"] objectForKey:@"type"] integerValue];

//                         int status =  [[self.allData objectForKey:@"status"] intValue];
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self setValuesToLabels:task];
                             [self adjustViewHeight];
                             if (type > 1) {
                                 //self.navigationItem.rightBarButtonItem = nil;
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
    }else if (self.allData) {
        NSMutableDictionary *task =[self.allData objectForKey:@"task"];
        self.taskId = [self.allData objectForKey:@"id"];
        self.otherSource = [NSMutableArray array];
        NSInteger type = [[[self.allData objectForKey:@"task"] objectForKey:@"type"] integerValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setValuesToLabels:task];
            [self adjustViewHeight];
            if (type > 1) {
                //self.navigationItem.rightBarButtonItem = nil;
            }
        });
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setValuesToLabels:(NSDictionary *)res{
    NSMutableDictionary *task =[self.allData objectForKey:@"task"];
    [task addEntriesFromDictionary:res];
    
    id categories = [task objectForKey:@"categories"];
    self.categoriesValueLabel.text = [categories isKindOfClass:[NSArray class]] ? [categories componentsJoinedByString:@" "] : categories;
    self.titleValueLabel.text = [task objectForKey:@"name"];
    self.startatValueLabel.text = [task objectForKey:@"start_at"];
    self.deadlineValueLabel.text = [task objectForKey:@"deadline"];
    self.bonusValueLabel.text = [task objectForKey:@"bonus"];
    self.organizerValueLabel.text = [task objectForKey:@"owner"];
    self.actorValueLabel.text = @"actor";
    NSString *desc = [task objectForKey:@"desc"];
    self.descValueTextView.text = desc;

    self.locationValueLabel.text = [task objectForKey:@"place"];
}
- (void)adjustViewHeight{
    NSString *desc = self.descValueTextView.text;
    CGSize size = [desc sizeWithFont:self.descValueTextView.font constrainedToSize:CGSizeMake(self.descValueTextView.frame.size.width, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    float height = size.height + 15;

    CGRect f = self.descValueTextView.frame;
    self.descValueTextView.frame = CGRectMake(f.origin.x, f.origin.y, f.size.width, height);
    
//    self.borderScrollView.contentSize = CGSizeMake(self.borderScrollView.contentSize.width, f.origin.y + self.descValueTextView.frame.size.height + 4 + self.contentView.contentSize.height);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.section == 1 && indexPath.row == 1) {
//        HJMapViewController *map = [[HJMapViewController alloc] initWithNibName:@"HJMapViewController" bundle:nil];
//        [self.navigationController pushViewController:map animated:YES];
//    }else if (indexPath.section == 3 && indexPath.row == 0) {
//        HJProfileViewController *profile = [[HJProfileViewController alloc] initWithNibName:@"HJProfileViewController" bundle:nil];
//        profile.profileId = [self.allData objectForKey:@"owner"];
//        profile.profileId = @"5031f3280b11356772000005";
//        [self.navigationController pushViewController:profile animated:YES];
//    }
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.backgroundView.layer.cornerRadius = 0;
}

- (void)handleTapOnLocation:(id)sender {
    HJMapViewController *map = [[HJMapViewController alloc] initWithNibName:@"HJMapViewController" bundle:nil];
//    map.delegate = self;
    map.maxPins = 0;
    [self.navigationController pushViewController:map animated:YES];
}
- (void)handleTapOnOrganizer:(id)sender {
    NSDictionary *task =[self.allData objectForKey:@"task"];
    HJProfileViewController *profile = [[HJProfileViewController alloc] initWithNibName:@"HJProfileViewController" bundle:nil];
    profile.profileId = [task objectForKey:@"profile_id"];
    [self.navigationController pushViewController:profile animated:YES];
}

- (void)barButtonTapped:(id)sender {
    NSInteger type = [[[self.allData objectForKey:@"task"] objectForKey:@"type"] integerValue];
    int status =  [[self.allData objectForKey:@"status"] intValue];

    UIActionSheet *select;
    if ([self.allData objectForKey:@"role"] && [[self.allData objectForKey:@"role"] intValue] == 10) {
        if (type == 0 || type == 1) {
            select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"关闭任务" otherButtonTitles:@"编辑任务", nil];
        }else if (type >= 2) {
        }
    }else{
        //Log(@"%i", status);
        switch (status) {
            case 0:
            {
                if (type == 0 || type == 1) {
                    select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"完成任务", @"转交任务", nil];
                }else if (type >= 2) {
                    //select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"寻宝", @"完成任务", nil];
                }
                break;
            }
            case 1:
            case 2:
            {
                if (type == 0 || type == 1) {
                    select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"完成任务", @"转交任务", nil];
                }else if (type >= 2) {
                    select = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"完成任务", @"转交任务", nil];
                }
                break;
            }
            default:
                break;
        }
    }
    [select showFromBarButtonItem:sender animated:YES];
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
            [UMSNSService presentSNSInController:self appkey:UMENG_KEY status:@"我在号角参加了任务" image:nil platform:UMShareToTypeSina];
        }else if ([title isEqualToString:@"寻宝"]) {
            HJPropsViewController *viewController = [[HJPropsViewController alloc] initWithNibName:@"HJPropsViewController" bundle:nil];
            UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:viewController];
            //centerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentModalViewController:centerController animated:YES];
        }else if ([title isEqualToString:@"完成任务"]) {
            HJRecordViewController *viewController5 = [[HJRecordViewController alloc] initWithNibName:@"HJRecordViewController" bundle:nil];
//            [self.navigationController pushViewController:viewController5 animated:YES];
//            [viewController5 initDataSource:@[task]];
            
            viewController5.shouldAddCancelButton = YES;
            viewController5.type = HJRecordTypeFinish;
            UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:viewController5];
            //centerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentModalViewController:centerController animated:YES];
            viewController5.taskId = self.taskId;
            [viewController5 initDataSource:@[task]];

        }else if ([title isEqualToString:@"加入任务"]) {
            [self joinButtonTapped:nil];
        }else if ([title isEqualToString:@"编辑任务"]) {
            NSLog(@"%@", @"should Modify");
            NSDictionary *source = @{@"id": self.taskId, @"name":self.titleValueLabel.text, @"desc":self.descValueTextView.text, @"deadline":self.deadlineValueLabel.text, @"bonus":self.bonusValueLabel.text, @"start_at":self.startatValueLabel.text, @"place":self.locationValueLabel.text, @"actor":self.actorValueLabel.text, @"categories":self.categoriesValueLabel.text};
            HJCreateTaskViewController *creator = [[HJCreateTaskViewController alloc] initWithNibName:@"HJCreateTaskViewController" bundle:nil];
            creator.type = HJTaskTypeIndependentModify;
            [creator reloadWithDataSource:source andDelegate:self];
            [self.navigationController pushViewController:creator animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"%@", @"should close the task");
    }
}

- (void)joinButtonTapped:(id)sender {
    NSDictionary *params = @{@"id": self.taskId, @"desc": @"任务描述中文English"};
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

- (void)recordButtonTapped:(id)sender {
    NSDictionary *params = @{@"id": self.taskId, @"desc": @"任务描述中文English"};
    MIRequestManager *manager = [MIRequestManager requestManager];
    [manager apiFinishTask:params withFinishHandler:^(NSURLResponse *response, NSData *rData, NSError *error)
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
    [self setValuesToLabels:task];
}

- (void)profileSelected:(NSArray *)selectedProfiles {
    Log(@"profileSelected %@", selectedProfiles);
    NSMutableArray *profiles = [NSMutableArray array];
    for (NSDictionary *profile in selectedProfiles) {
        [profiles addObject:[profile objectForKey:@"profile_id"]];
    }
    NSDictionary *params = @{@"act": @"invite", @"task_id": self.taskId, @"task_type": @"0", @"profiles": profiles};
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

@end
