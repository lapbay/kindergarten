//
//  HJIntelligenceViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshViewController.h"

typedef enum {
    HJIntelligenceViewTypeFeeds = 0,
    HJIntelligenceViewTypeNotifications,
    HJIntelligenceViewTypeMessages
} HJIntelligenceViewType;

@interface HJIntelligenceViewController : RefreshViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    IBOutlet UITableView *contentView;
}

//@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) HJIntelligenceViewType type;
@property(nonatomic, assign) NSInteger selectedIndex;

@property (retain, nonatomic) IBOutlet UITableView *contentView;
@property (retain, nonatomic) NSMutableArray *dataSource;

@end
