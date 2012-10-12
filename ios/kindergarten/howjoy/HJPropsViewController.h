//
//  HJPropsViewController.h
//  howjoy
//
//  Created by Wu Chang on 9/12/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <StoreKit/StoreKit.h>

@interface HJPropsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    SystemSoundID soundID;
    IBOutlet UITableView *contentView;
    IBOutlet UIView *animationViewContainer;
    IBOutlet UIImageView *animationView;
    IBOutlet UIImageView *animationView1;
}

@property (retain, nonatomic) IBOutlet UITableView *contentView;
@property (retain, nonatomic) IBOutlet UIView *animationViewContainer;
@property (retain, nonatomic) IBOutlet UIImageView *animationView;
@property (retain, nonatomic) IBOutlet UIImageView *animationView1;

@property (retain, nonatomic) NSArray *productsArray;
@property (assign, nonatomic) NSInteger currentProductIndex;

@property (retain, nonatomic) NSMutableArray *dataSource;
@property (retain, nonatomic) NSMutableDictionary *recordData;

@end
