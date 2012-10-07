//
//  HJAppDelegate.h
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MILoginViewController.h"
#import "IIViewDeckController.h"

@interface HJAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (retain, nonatomic) MILoginViewController *loginController;
@property (retain, nonatomic) IIViewDeckController *deckController;

@end
