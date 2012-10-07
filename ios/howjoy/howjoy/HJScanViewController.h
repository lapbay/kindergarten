//
//  PGScanSubViewController.h
//  gdst
//
//  Created by com milan on 12-5-22.
//  Copyright (c) 2012年 unique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "MIRequestManager+API.h"
#import "MBProgressHUD.h"

@interface HJScanViewController : ZBarReaderViewController <ZBarReaderDelegate, UIAlertViewDelegate> {
    UIImageView *resultImage;
    UITextView *resultText;
}

@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextView *resultText;

- (IBAction) scanButtonTapped;
- (void) settleScanButton;

@end
