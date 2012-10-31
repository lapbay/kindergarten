//
//  HJAppDelegate.m
//  howjoy
//
//  Created by Wu Chang on 8/10/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJAppDelegate.h"

#import "HJIntelligenceViewController.h"
#import "HJRecordViewController.h"
#import "HJTaskCenterViewController.h"
#import "HJProfileViewController.h"
#import "HJMoreViewController.h"
#import "MIMoreViewController.h"
#import "MobClick.h"
#import "MILeftViewController.h"

@implementation HJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"MIShouldAddLoginView" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* n){
        self.loginController = [[MILoginViewController alloc] initWithNibName:@"MILoginViewController" bundle:nil];
//        [self.tabBarController.view addSubview: self.loginController.view];
        [self.tabBarController.view addSubview: self.loginController.view];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"MILoginDidFinishedSuccessfully" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* n){
        [self.tabBarController setSelectedIndex:1];
    }];

    HJIntelligenceViewController *viewController1 = [[HJIntelligenceViewController alloc] initWithNibName:@"HJIntelligenceViewController" bundle:nil];
    HJTaskCenterViewController *viewController2 = [[HJTaskCenterViewController alloc] initWithNibName:@"HJTaskCenterViewController" bundle:nil];
    HJProfileViewController *viewController3 = [[HJProfileViewController alloc] initWithNibName:@"HJProfileViewController" bundle:nil];
//    HJMoreViewController *viewController4 = [[HJMoreViewController alloc] initWithNibName:@"HJMoreViewController" bundle:nil];
    MIMoreViewController *viewController4 = [[MIMoreViewController alloc] initWithNibName:@"MIMoreViewController" bundle:nil];
    
    UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    UINavigationController *navController4 = [[UINavigationController alloc] initWithRootViewController:viewController4];

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[navController1, navController2, navController3, navController4];
    self.window.rootViewController = self.tabBarController;

//    self.deckController =  [self setupIIViewDeckController];
//    self.window.rootViewController = self.deckController;

    BOOL isLoggedIn = [[MIStorage sharedManager] isLogin];
    if (isLoggedIn) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MILoginDidFinishedSuccessfully" object:nil];
    }else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MIShouldAddLoginView" object:nil];
    }

    [self.window makeKeyAndVisible];
    
    [MobClick startWithAppkey:UMENG_KEY reportPolicy:REALTIME channelId:nil];

    return YES;
}

- (IIViewDeckController *)setupIIViewDeckController {
    MILeftViewController *leftController = [[MILeftViewController alloc] initWithNibName:@"MILeftViewController" bundle:nil];
    HJTaskCenterViewController *centerViewController = [[HJTaskCenterViewController alloc] initWithNibName:@"HJTaskCenterViewController" bundle:nil];
    UINavigationController *centerController = [[UINavigationController alloc] initWithRootViewController:centerViewController];

    IIViewDeckController *deck =  [[IIViewDeckController alloc] initWithCenterViewController:centerController leftViewController:leftController];
    deck.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    //deck.navigationControllerBehavior = IIViewDeckNavigationControllerIntegrated;
    //deck.panningMode = IIViewDeckNavigationBarPanning;
    //deck.panningView = centerViewController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        deck.leftLedge = 50;
    }else{
        deck.leftLedge = 200;
    }
    
    centerViewController.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStyleBordered target:deck action:@selector(toggleLeftView)];
    return deck;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
