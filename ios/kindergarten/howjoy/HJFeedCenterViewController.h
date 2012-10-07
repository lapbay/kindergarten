//
//  HJFeedViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshViewController.h"

@interface HJFeedCenterViewController : RefreshViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *contentView;
}

@property (retain, nonatomic) IBOutlet UITableView *contentView;
@property (retain, nonatomic) NSMutableArray *dataSource;

@end
