//
//  HJTaskCell.m
//  howjoy
//
//  Created by Wu Chang on 8/22/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJTaskCell.h"

@implementation HJTaskCell
@synthesize placeLabel = _placeLabel;
@synthesize timeLabel = _timeLabel;
@synthesize countLabel = _countLabel;
@synthesize titleLabel = _titleLabel;

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
