//
//  MILeftViewController.h
//  bid
//
//  Created by com milan on 7/5/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MILeftViewController : UIViewController {
    IBOutlet UITableView *tableView;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *data;

@end
