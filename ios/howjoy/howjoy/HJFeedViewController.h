//
//  HJFeedViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/16/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJFeedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *contentView;
}

@property (retain, nonatomic) IBOutlet UITableView *contentView;
@property (retain, nonatomic) NSMutableArray *dataSource;

@end
