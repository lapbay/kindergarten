//
//  HJPropsViewController.h
//  howjoy
//
//  Created by Wu Chang on 9/12/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface HJPropsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    SystemSoundID soundID;
    IBOutlet UITableView *contentView;
    IBOutlet UIImageView *animationView;
}

@property (retain, nonatomic) IBOutlet UITableView *contentView;
@property (retain, nonatomic) IBOutlet UIImageView *animationView;

@property (retain, nonatomic) NSMutableArray *dataSource;
@property (retain, nonatomic) NSMutableDictionary *recordData;

@end
