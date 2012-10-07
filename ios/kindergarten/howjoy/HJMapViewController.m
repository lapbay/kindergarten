//
//  HJMapViewController.m
//  howjoy
//
//  Created by Wu Chang on 8/23/12.
//  Copyright (c) 2012 HowJoy. All rights reserved.
//

#import "HJMapViewController.h"

@interface HJMapViewController ()

@end

@implementation HJMapViewController
@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"地点", @"Location");
        self.annotations = [NSMutableArray array];
        self.dropedPins = [NSMutableArray array];
        self.maxPins = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *NavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = NavButton;

    self.mapView.delegate =self;
    self.mapView.showsUserLocation = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:longPress];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 39.9f;
    coordinate.longitude = 116.4f;
    MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
    ann.coordinate = coordinate;
    [ann setTitle:@"某地"];
    [ann setSubtitle:@"Some place"];
    [self.mapView addAnnotation:ann];
    
//    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    locationManager.distanceFilter = 1000.0f;
//    [locationManager startUpdatingLocation];
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.05;
    theSpan.longitudeDelta = 0.05;
    MKCoordinateRegion theRegion;
//    theRegion.center = [[locationManager location] coordinate];
    theRegion.center = coordinate;
    theRegion.span = theSpan;
    
    [self.mapView setRegion:theRegion];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    static NSString* annotationIdentifier = @"com.howjoy.despin";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
    }
    return pinView;
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    if (self.maxPins > 0) {
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        annot.coordinate = touchMapCoordinate;
        [self.mapView addAnnotation:annot];
        NSArray *coor = @[[NSNumber numberWithFloat:touchMapCoordinate.longitude], [NSNumber numberWithFloat:touchMapCoordinate.latitude]];
        
        if (self.dropedPins.count < self.maxPins) {
            [self.dropedPins addObject:coor];
            [self.annotations addObject:annot];
        }else{
            [self.annotations addObject:annot];
            MKPointAnnotation *lastAnnot = [self.annotations objectAtIndex:0];
            [self.mapView removeAnnotation:lastAnnot];
            [self.annotations removeObjectAtIndex:0];
            [self.dropedPins addObject:coor];
            [self.dropedPins removeObjectAtIndex:0];
        }
        if ([self.delegate respondsToSelector:@selector(didDropPinAt:)]) {
            [self.delegate didDropPinAt:coor];
        }
    }
}

- (IBAction)doneButtonTapped : (id) sender {
    if ([self.delegate respondsToSelector:@selector(didEndActionWithCoordinates:)]) {
        [self.delegate didEndActionWithCoordinates:self.dropedPins];
    }
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] animated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

@end
