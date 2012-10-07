//
//  HJTaskSeriesViewController.h
//  howjoy
//
//  Created by Wu Chang on 9/13/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJCreateTaskViewController.h"

@interface HJTaskSeriesViewController : UITableViewController <UIActionSheetDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    HJCreateTaskType type;
}

@property(nonatomic, assign) HJCreateTaskType type;

@property (strong, nonatomic) HJCreateTaskViewController *createViewController;
@property (retain, nonatomic) NSMutableDictionary *allData;
@property (retain, nonatomic) NSMutableDictionary *dataSource;
@property (retain, nonatomic) NSDictionary *dataTitles;
@property (retain, nonatomic) NSArray *dataKeys;
@property (retain, nonatomic) NSDictionary *pickerData;
@property (retain, nonatomic) NSIndexPath *indexPathEditing;

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIPickerView *dataPicker;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (retain, nonatomic) NSString *taskId;
@property (assign, nonatomic) BOOL dataSaved;
@property (assign, nonatomic) BOOL dataInitialized;
@property (assign, nonatomic) BOOL allowToShowEditors;

- (void)didModifyTask:(NSDictionary *)task;
- (void)profileSelected:(NSArray *)selectedProfiles;

@end
