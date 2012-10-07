//
//  HJCreateTaskViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/13/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HJMapViewController.h"

typedef enum {
    HJTaskTypeIndependentCreate = 0,
    HJTaskTypeIndependentModify,
    HJTaskTypeSeriesCreate,
    HJTaskTypeSeriesModify,
    HJTaskTypeView
} HJCreateTaskType;

@interface HJCreateTaskViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, HJMapViewDelegate> {
    IBOutlet UITableView *contentView;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) HJCreateTaskType type;

@property (retain, nonatomic) IBOutlet UITableView *contentView;
@property (retain, nonatomic) NSDictionary *pickerData;
@property (retain, nonatomic) NSMutableDictionary *dataSource;
@property (retain, nonatomic) NSDictionary *dataTitles;
@property (retain, nonatomic) NSArray *dataKeys;
@property (retain, nonatomic) NSIndexPath *indexPathEditing;

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIPickerView *dataPicker;
@property (strong, nonatomic) UIDatePicker *datePicker;

- (void)reloadWithDataSource:(NSDictionary *)source andDelegate: (id) dele;
- (void)reloadWithDataSource:(NSDictionary *)source andDataKeys:(NSArray *)keys andDelegate: (id) dele;

@end
