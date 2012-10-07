//
//  MIMoreViewController.h
//  photo
//
//  Created by Wu Chang on 7/24/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIRequestManager+API.h"
#import "MBProgressHUD.h"

@interface MIMoreViewController : UITableViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, MIRequestDelegate>

@property (retain, nonatomic) NSMutableArray *data;
@property (retain, nonatomic) MBProgressHUD *hud;
@property (retain, nonatomic) NSString *appStoreURL;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
