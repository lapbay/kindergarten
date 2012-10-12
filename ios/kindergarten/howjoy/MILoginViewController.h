//
//  MILoginViewController.h
//  gdst
//
//  Created by com milan on 12-5-23.
//  Copyright (c) 2012年 unique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIRequestManager+API.h"
#import "Reachability.h"

@interface MILoginViewController : UIViewController <MIRequestDelegate, UITextFieldDelegate> {
    IBOutlet UITextField *userField;
    IBOutlet UITextField *pswdField;
    IBOutlet UIButton *submitButton;
}

@property (retain, nonatomic) IBOutlet UITextField *userField;
@property (retain, nonatomic) IBOutlet UITextField *pswdField;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)loginButtonTapped : (id) sender;
- (void) doAction: (NSNumber *) index;

@end
