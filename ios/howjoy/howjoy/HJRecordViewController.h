//
//  HJRecordViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/18/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef enum {
    HJRecordTypeCheckin = 0,
    HJRecordTypeRecord = 1,
    HJRecordTypeFinish = 2,
} HJRecordType;

@interface HJRecordViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    HJRecordType type;
    IBOutlet UIImageView *thumbnailView;
    IBOutlet UITextView *textRecorder;
    IBOutlet MKMapView *mapView;
    IBOutlet UIScrollView *friendsView;
}

@property (assign, nonatomic) HJRecordType type;
@property (retain, nonatomic) NSString *typeString;
@property (retain, nonatomic) NSString *taskId;
@property (retain, nonatomic) NSString *superTaskId;

@property (retain, nonatomic) UIPopoverController *popoverController;
@property (retain, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (retain, nonatomic) IBOutlet UITextView *textRecorder;
@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UIScrollView *friendsView;
@property(nonatomic, retain) IBOutlet UIButton *taskSelectorButton;

@property (retain, nonatomic) NSMutableDictionary *recordData;
@property (retain, nonatomic) NSMutableArray *dataSource;
@property (retain, nonatomic) NSMutableArray *selectedFriends;

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIPickerView *dataPicker;
@property (assign, nonatomic) BOOL shouldAddCancelButton;

-(void)initDataSource:(NSArray *)source;
- (void)profileSelected:(NSArray *)selectedProfiles;

@end
