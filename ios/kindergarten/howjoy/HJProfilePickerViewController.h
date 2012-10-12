//
//  HJProfilePickerViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/30/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HJProfilePickerSelectionTypeMultiple = 0,
    HJProfilePickerSelectionTypeSingle
} HJProfilePickerSelectionType;


@interface HJProfilePickerViewController : UITableViewController

@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) HJProfilePickerSelectionType selectionType;

@property (retain, nonatomic) NSMutableArray *dataSource;
@property (retain, nonatomic) NSMutableDictionary *selected;

@end
