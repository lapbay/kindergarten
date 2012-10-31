//
//  HJPeopleViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/13/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    HJTableContentFeedType = 0,
    HJTableContentTaskType,
    HJTableContentPhotoType,
    HJTableContentFriendType
}HJTableContentType;
@interface HJProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    IBOutlet UITableView *contentView;
    HJTableContentType hjContentType;
}
@property (nonatomic,assign)  BOOL shouldHideButtons;
@property (nonatomic,assign)  HJTableContentType hjContentType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *contentSwitchSegment;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (retain, nonatomic) NSString *profileId;
@property (retain, nonatomic) IBOutlet UITableView *contentView;

@property (retain, nonatomic) NSMutableDictionary *profileData;
@property (retain, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UILabel *introductionLabel;
- (IBAction)tabDidSwitch:(id)sender;

@end
