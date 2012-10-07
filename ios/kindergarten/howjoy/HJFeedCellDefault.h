//
//  HJFeedCellDefault.h
//  howjoy
//
//  Created by Wu Chang on 8/22/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJFeedCellDefault : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *placeLabel;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *countLabel;
}

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *placeLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *countLabel;

@end
