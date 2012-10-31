//
//  HJTaskViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJTaskViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate> {
}

@property (retain, nonatomic) IBOutlet UIScrollView *borderScrollView;
@property (retain, nonatomic) IBOutlet UILabel *categoriesValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *titleValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *startatValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *deadlineValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *actorValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *bonusValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *organizerValueLabel;
@property (retain, nonatomic) IBOutlet UILabel *locationValueLabel;
@property (retain, nonatomic) IBOutlet UITextView *descValueTextView;

@property (retain, nonatomic) NSMutableArray *otherSource;
@property (retain, nonatomic) NSMutableDictionary *allData;
@property (retain, nonatomic) NSString *taskId;

- (id)initWithNibName:(NSString *)nibNameOrNil id:(NSString *)tid;
- (void)didModifyTask:(NSDictionary *)info;
- (void)profileSelected:(NSArray *)selectedProfiles;

@end
