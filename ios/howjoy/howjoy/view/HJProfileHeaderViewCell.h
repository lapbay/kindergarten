//
//  HJProfileHeaderViewCell.h
//  howjoy
//
//  Created by iSoul on 12-9-4.
//  Copyright (c) 2012年 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJProfileHeaderViewCell : UITableViewCell {
    UIImageView * _avatarImageView;
    UILabel * _introducationLabel;
    UILabel * _nameLabel;
    UILabel * _rankLabel;
    UILabel * _levelLabel;
}
@property (nonatomic,strong) IBOutlet UILabel * nameLabel;
@property (nonatomic,strong) IBOutlet UILabel * rankLabel;
@property (nonatomic,strong) IBOutlet UILabel * levelLabel;
@property (nonatomic,strong) IBOutlet UIImageView * avatarImageView;
@property (nonatomic,strong) IBOutlet UILabel * introducationLabel;
@end