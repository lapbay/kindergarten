//
//  HJMapViewController.h
//  howjoy
//
//  Created by Wu Chang on 8/23/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol HJMapViewDelegate <NSObject>
@required
@optional
- (void)didDropPinAt:(NSArray *) coordinate;
- (void)didEndActionWithCoordinates:(NSArray *) coordinates;
@end

@interface HJMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    IBOutlet MKMapView *mapView;
}

@property(nonatomic, assign) id <HJMapViewDelegate> delegate;
@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) NSMutableArray *dropedPins;
@property(nonatomic, retain) NSMutableArray *annotations;
@property(nonatomic, assign) NSInteger maxPins;

@end
