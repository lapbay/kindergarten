//
//  HJEditViewController.h
//  gdst
//
//  Created by Wu Chang on 7/22/12.
//  Copyright (c) 2012 unique. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HJEditTypeDefault = 0,
    HJEditTypeSendMessage,
} HJEditType;

@interface HJEditViewController : UIViewController {
    IBOutlet UITextView *editView;
    IBOutlet UIDatePicker *dateView;
}

@property(nonatomic, assign) HJEditType editType;
@property (retain, nonatomic) IBOutlet UITextView *editView;
@property (retain, nonatomic) IBOutlet UIDatePicker *dateView;
@property (retain, nonatomic) id delegate;
@property (assign, nonatomic) NSInteger type;

- (IBAction)confirm: (id) sender;

@end
