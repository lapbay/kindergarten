//
//  HJSearchViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/27/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIRequestManager+API.h"

typedef enum {
    HJSearchViewTypeTask = 0,
    HJSearchViewTypeProfile
} HJSearchViewType;

@interface HJSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UISearchBar *searchBar;
    IBOutlet UITableView *contentView;
}

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *contentView;

@property (assign, nonatomic) HJSearchViewType type;
@property (retain, nonatomic) NSMutableArray *dataSource;

-(void) doSearch;

@end
