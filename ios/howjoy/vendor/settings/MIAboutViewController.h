//
//  MIAboutViewController.h
//  photo
//
//  Created by Wu Chang on 7/24/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIRequestManager+API.h"
#import "MBProgressHUD.h"

@interface MIAboutViewController : UITableViewController

@property (retain, nonatomic) NSMutableArray *data;
@property (retain, nonatomic) MBProgressHUD *hud;

@end
