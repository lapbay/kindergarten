//
//  HJTaskCenterViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/13/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJTaskCenterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    IBOutlet UITableView *contentView;
}

@property (retain, nonatomic) IBOutlet UITableView *contentView;
@property (retain, nonatomic) NSMutableArray *dataSource;
@property (assign, nonatomic) NSInteger sourceType;

- (IBAction)createButtonTapped : (id) sender;

@end
