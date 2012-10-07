//
//  HJFeedCellDefault.m
//  howjoy
//
//  Created by Wu Chang on 8/22/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJFeedCellDefault.h"

@implementation HJFeedCellDefault
@synthesize timeLabel = _timeLabel;
@synthesize countLabel = _countLabel;
@synthesize titleLabel = _titleLabel;
@synthesize placeLabel = _placeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
