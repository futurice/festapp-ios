//
//  MapViewController.m
//  FestApp
//

#import "MapViewController.h"
#import "CalloutView.h"
#import "UIViewController+Additions.h"
#import "FestAppDelegate.h"
#import "TimelineViewController.h"
#import "Artist.h"
#import "NSDate+Additions.h"
#import "FestDataManager.h"

@interface MapViewController (hidden)

- (void)focusOnPoint:(CGPoint)point animated:(BOOL)animated ignorePointsOutsideMap:(BOOL)ignoreOutsidePoints;
- (void)focusOnUserLocationAnimated:(BOOL)animated;
- (void)updateUserLocationDisplayAnimated:(BOOL)animated;
- (CGPoint)scaleCorrectedPointFromPoint:(CGPoint)point;
- (BOOL)pointWithinMapArea:(CGPoint)point;
- (void)selectStageView:(UIView *)stageView;
- (void)hilightAllStages;
- (IBAction)calloutDisclosureButtonTapped;

@end

@implementation MapViewController

@synthesize mapScrollView;
@synthesize mapImageView;
@synthesize userLocationImageView;
@synthesize userLocationCalloutView;
@synthesize userLocationLabel;
@synthesize userLocationAccuracyLabel;
@synthesize gpsInfoView;
@synthesize gpsInfoLabel;
@synthesize calloutView;
@synthesize stageViews;
@synthesize stageHilightCurtain;

@synthesize userLocation;
@synthesize locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];

    mapScrollView.backgroundColor = [UIColor blackColor];

	UIImage *mapImage = [UIImage imageNamed:@"map"];
	mapImageView.image = mapImage;
	mapImageView.frame = CGRectMake(0, 0, mapImage.size.width*kMapScaleFactor, mapImage.size.height*kMapScaleFactor);
    mapImageView.userInteractionEnabled = YES;
	mapScrollView.contentSize = mapImageView.frame.size;

    gpsInfoView.hidden = YES;

    UIImage *locationImage = [UIImage imageNamed:@"userlocation"];
    self.userLocationImageView = [[UIImageView alloc] initWithImage:locationImage];
    userLocationImageView.frame = CGRectMake(0, 0, locationImage.size.width, locationImage.size.height);
    userLocationImageView.hidden = YES;
    userLocationImageView.userInteractionEnabled = YES;

    userLocationCalloutView.hidden = YES;

    [mapScrollView addSubview:userLocationImageView];

    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationFailCount = 0;

    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTappedOnMap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [mapScrollView addGestureRecognizer:singleTapRecognizer];

    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappedOnMap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [mapScrollView addGestureRecognizer:doubleTapRecognizer];

    self.calloutView = [[CalloutView alloc] init];
    [calloutView setTargetOnButtonAction:self withSelector:@selector(calloutDisclosureButtonTapped)];
    [mapScrollView addSubview:calloutView];
    calloutView.hidden = YES;

    self.stageHilightCurtain = [[UIView alloc] init];
    stageHilightCurtain.frame = mapImageView.frame;
    stageHilightCurtain.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
    [mapImageView addSubview:stageHilightCurtain];
    stageHilightCurtain.hidden = YES;

    // Subscribe
    FestDataManager *dataManager = [FestDataManager sharedFestDataManager];

    [[dataManager signalForResource:FestResourceStages] subscribeNext:^(NSArray *stages) {
        [self setStages:stages];
    }];

    // TODO: Fix hack
    BOOL isiPhone5 = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
                    ([UIScreen mainScreen].bounds.size.height > 480);
    mapScrollView.minimumZoomScale = (isiPhone5) ? 0.80f : 0.602f;
    mapScrollView.maximumZoomScale = 1.5;
    mapScrollView.zoomScale = mapScrollView.minimumZoomScale;
    mapScrollView.contentOffset = CGPointMake(215, 0);

    [mapScrollView bringSubviewToFront:userLocationImageView];
    [mapScrollView bringSubviewToFront:userLocationCalloutView];

    firstViewing = YES;
}

- (void)setStages:(NSArray *)stagesInfo
{
    // Clean-up previous
    for (UIImageView *stageImageView in self.stageViews) {
        [stageImageView removeFromSuperview];
    }

    NSMutableArray *stageButtonsArr = [NSMutableArray arrayWithCapacity:[stagesInfo count]];

    int stageIndex = 0;
    for (NSDictionary *stageInfo in stagesInfo) {

        NSString *stageName = [stageInfo valueForKey:@"name"];
        CGPoint stageOrigin;
        stageOrigin.x = [[stageInfo valueForKey:@"x"] intValue]*kMapScaleFactor;
        stageOrigin.y = [[stageInfo valueForKey:@"y"] intValue]*kMapScaleFactor;
        CGSize stageSize;
        stageSize.width = [[stageInfo valueForKey:@"width"] intValue]*kMapScaleFactor;
        stageSize.height = [[stageInfo valueForKey:@"height"] intValue]*kMapScaleFactor;

        UIImage *stageImage = [UIImage imageNamed:[NSString stringWithFormat:@"stage-%@.png", [stageName lowercaseString]]];
        UIImageView *stageImageView = [[UIImageView alloc] initWithImage:stageImage];
        stageImageView.frame = CGRectMake(stageOrigin.x, stageOrigin.y, stageSize.width, stageSize.height);
        stageImageView.tag = stageIndex;
        stageImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        stageIndex++;

        NSLog(@"placing stage %@ at %.0f, %.0f with size %.0f x %.0f", stageName, stageOrigin.x, stageOrigin.y, stageSize.width, stageSize.height);

        [mapImageView addSubview:stageImageView];

        [stageButtonsArr addObject:stageImageView];
    }

    self.stageViews = stageButtonsArr;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (userLocation != nil) {
        [self updateUserLocationDisplayAnimated:NO];
    } else {
        userLocationCalloutView.hidden = YES;
    }
    [locationManager startUpdatingLocation];

    userLocationLabel.text = NSLocalizedString(@"map.userlocation.label", @"");

    if (firstViewing) {
        [self hilightAllStages];
        firstViewing = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabBarController sendEventToTracker:self.title];
    if (userLocation != nil) {
        [self focusOnUserLocationAnimated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [locationManager stopUpdatingLocation];
}


#pragma mark Coordinate translations

- (CGPoint)pointFromCoordinate:(CLLocationCoordinate2D)coordinate
{
    double latitude = coordinate.latitude;
    double longitude = coordinate.longitude;

    double referenceX = 1342;
    double referenceY = 736;

    double latitudeGain = 0.00412661358/100;
    double longitudeGain = 0.00507205725/100;
    double latitudeGainXPixelChange = -4.74;
    double latitudeGainYPixelChange = -7.56;
    double longitudeGainXPixelChange = 4.7;
    double longitudeGainYPixelChange = -2.92;

    // This is the real thing:
    double referenceLatitude = 60.42836515775148;
	double referenceLongitude = 22.18308629415958;

    double changeInLatitude = (latitude - referenceLatitude) / latitudeGain;
    double changeInX = changeInLatitude  *latitudeGainXPixelChange;
    double changeInY = changeInLatitude  *latitudeGainYPixelChange;

    double changeInLongitude = (longitude - referenceLongitude) / longitudeGain;
    changeInX += changeInLongitude  *longitudeGainXPixelChange;
    changeInY += changeInLongitude  *longitudeGainYPixelChange;

    CGPoint point;
    point.x = (int) ((referenceX + changeInX)  *kMapScaleFactor);
    point.y = (int) ((referenceY + changeInY)  *kMapScaleFactor);
    return point;
}

- (CGPoint)scaleCorrectedPointFromPoint:(CGPoint)point
{
    CGPoint scaleCorrectedPoint;
    scaleCorrectedPoint.x = (int) (mapScrollView.zoomScale  *point.x);
    scaleCorrectedPoint.y = (int) (mapScrollView.zoomScale  *point.y);
    return scaleCorrectedPoint;
}

- (void)focusOnUserLocationAnimated:(BOOL)animated
{
    CGPoint userPoint = [self pointFromCoordinate:userLocation.coordinate];
    [self focusOnPoint:userPoint animated:YES ignorePointsOutsideMap:YES];
}

- (void)focusOnPoint:(CGPoint)point animated:(BOOL)animated ignorePointsOutsideMap:(BOOL)ignoreOutsidePoints
{
    point = [self scaleCorrectedPointFromPoint:point];
    if (ignoreOutsidePoints && ![mapImageView pointInside:point withEvent:nil]) {

        return;
    }

    CGPoint contentOffset = CGPointMake(point.x - mapScrollView.width/2, point.y - mapScrollView.height/2);
    if (contentOffset.x < 0) { contentOffset.x = 0; }
    if (contentOffset.y < 0) { contentOffset.y = 0; }
    if (contentOffset.x > mapScrollView.contentSize.width-mapScrollView.width) { contentOffset.x = mapScrollView.contentSize.width-mapScrollView.width; }
    if (contentOffset.y > mapScrollView.contentSize.height-mapScrollView.height) { contentOffset.y = mapScrollView.contentSize.height-mapScrollView.height; }
    [mapScrollView setContentOffset:contentOffset animated:animated];
}

- (BOOL)pointWithinMapArea:(CGPoint)point
{
    if (point.x < 0 || point.x > mapImageView.width*mapScrollView.zoomScale ||
        point.y < 0 || point.y > mapImageView.height*mapScrollView.zoomScale) {

        return NO;

    } else {

        return YES;
    }
}

- (IBAction)singleTappedOnMap:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint tapPoint = [tapRecognizer locationInView:mapImageView];
    // NSLog(@"tappoint x:%f y:%f", tapPoint.x, tapPoint.y);

    CGPoint tapPointWithoutScale;
    tapPointWithoutScale.x = tapPoint.x * mapScrollView.zoomScale;
    tapPointWithoutScale.y = tapPoint.y * mapScrollView.zoomScale;
    if (!calloutView.hidden && calloutView.showDetailDisclosureButton && (tapPointWithoutScale.x > calloutView.x) && (tapPointWithoutScale.x < calloutView.x+calloutView.width) && (tapPointWithoutScale.y > calloutView.y) && (tapPointWithoutScale.y < calloutView.y+calloutView.height)) {
        if (tapPointWithoutScale.x >= calloutView.x+calloutView.detailDisclosureButton.x &&
            tapPointWithoutScale.x <= calloutView.x+calloutView.detailDisclosureButton.x+calloutView.detailDisclosureButton.width &&
            tapPointWithoutScale.y >= calloutView.y+calloutView.detailDisclosureButton.y &&
            tapPointWithoutScale.y <= calloutView.y+calloutView.detailDisclosureButton.y+calloutView.detailDisclosureButton.height) {

            [self calloutDisclosureButtonTapped];
        }
        // return;
    }

    if (userLocation != nil && userLocationCalloutView.hidden) {

        CGPoint userPoint = [self pointFromCoordinate:userLocation.coordinate];
        float xDiff = tapPoint.x - userPoint.x;
        float yDiff = tapPoint.y - userPoint.y;
        float distanceFromUserPoint = sqrtf(xDiff*xDiff + yDiff*yDiff);

        // NSLog(@"userpoint x:%f y:%f", userPoint.x, userPoint.y);

        if (distanceFromUserPoint < userLocationImageView.width/2) {
            userLocationCalloutView.frame = CGRectMake((int)(userLocationImageView.x+userLocationImageView.width/2-userLocationCalloutView.width/2), (int)(userLocationImageView.y+userLocationImageView.height/2-userLocationCalloutView.height-3), userLocationCalloutView.width, userLocationCalloutView.height);
            [self beginFadingAnimationWithDuration:0.5 withView:self.view];
            userLocationCalloutView.hidden = NO;
            [UIView commitAnimations];
            return;
        }
    }

    for (UIView *stageView in stageViews) {

        if (tapPoint.x >= stageView.x && tapPoint.x <= (stageView.x + stageView.width) &&
            tapPoint.y >= stageView.y && tapPoint.y <= (stageView.y + stageView.height)) {

            [self selectStageView:stageView withHilightCurtain:YES];
            return;
        }
    }

    [self selectStageView:nil];

    if (!userLocationCalloutView.hidden) { // && [self pointWithinMapArea:userLocationImageView.center]) {
        [self beginFadingAnimationWithDuration:0.5 withView:self.view];
        userLocationCalloutView.hidden = YES;
        [UIView commitAnimations];
    }
}

- (IBAction)doubleTappedOnMap:(UITapGestureRecognizer *)tapRecognizer
{
    if (mapScrollView.zoomScale < mapScrollView.maximumZoomScale) {
        [mapScrollView setZoomScale:mapScrollView.maximumZoomScale animated:YES];
    } else {
        [mapScrollView setZoomScale:mapScrollView.minimumZoomScale animated:YES];
    }
}

- (IBAction)calloutDisclosureButtonTapped
{
    /*
    TimelineViewController *timelineViewController = ((FestAppDelegate *) [[UIApplication sharedApplication] delegate]).timelineViewController;
    [self.tabBarController performSelector:@selector(setSelectedViewController:) withObject:timelineViewController.navigationController afterDelay:0.1];

    NSString *venueName = (timelineViewController.venues)[(NSUInteger) selectedStageView.tag];
    Gig *nextGig = [timelineViewController nextGigForDate:[NSDate date] onVenue:venueName];

    [timelineViewController setSelectedDay:[nextGig.begin sameDateWithMidnightTimestamp]];
    [timelineViewController setSelectedVenue:venueName];
    [timelineViewController performSelector:@selector(scrollToGig:) withObject:nextGig afterDelay:0.3];
     */
}

- (void)updateUserLocationDisplayAnimated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
    }
    CGPoint userLocationPoint = [self scaleCorrectedPointFromPoint:[self pointFromCoordinate:userLocation.coordinate]];
    userLocationImageView.frame = CGRectMake((int)(userLocationPoint.x - userLocationImageView.width/2), (int)(userLocationPoint.y - userLocationImageView.height/2), userLocationImageView.width, userLocationImageView.height);
    userLocationCalloutView.frame = CGRectMake((int)(userLocationPoint.x-userLocationCalloutView.width/2), (int)(userLocationPoint.y-userLocationCalloutView.height-3), userLocationCalloutView.width, userLocationCalloutView.height);
    if (animated) {
        [UIView commitAnimations];
    }

    CLLocation *turkuLocation =  [[CLLocation alloc] initWithLatitude:60.427972 longitude:22.182126];
    CLLocationDistance distanceFromTurku = [userLocation distanceFromLocation:turkuLocation];
    [[NSUserDefaults standardUserDefaults] setDouble:distanceFromTurku forKey:kDistanceFromFestKey];

    if ([self pointWithinMapArea:userLocationPoint]) {
        if (!gpsInfoView.hidden) {
            [self beginFadingAnimationWithDuration:0.4 withView:gpsInfoView];
            gpsInfoView.hidden = YES;
            [UIView commitAnimations];
        }
    } else {
        if (gpsInfoView.hidden) {
            [self beginFadingAnimationWithDuration:0.4 withView:gpsInfoView];
            gpsInfoView.hidden = NO;
            [UIView commitAnimations];
        }
    }

    userLocationAccuracyLabel.text = [NSString stringWithFormat:NSLocalizedString(@"map.accuracyformat", @""), userLocation.horizontalAccuracy];

    [mapScrollView bringSubviewToFront:userLocationImageView];
    [mapScrollView bringSubviewToFront:userLocationCalloutView];
}

- (void)selectStageView:(UIView *)stageView
{
    [self selectStageView:stageView withHilightCurtain:YES];
}

- (void)selectStageView:(UIView *)stageView withHilightCurtain:(BOOL)withHilightCurtain
{
    if (stageView != nil) {
/*
        if (withHilightCurtain && stageHilightCurtain.hidden) {
            [self beginFadingAnimationWithDuration:0.4 withView:stageHilightCurtain];
            stageHilightCurtain.hidden = NO;
        }

        TimelineViewController *timelineViewController = ((FestAppDelegate *) [[UIApplication sharedApplication] delegate]).timelineViewController;
        NSString *venueName = (timelineViewController.venues)[(NSUInteger) stageView.tag];
        Gig *nextGig = [timelineViewController nextGigForDate:[NSDate date] onVenue:venueName];

        if (nextGig != nil) {
            calloutView.title = nextGig.artistName;
            calloutView.subtitle = nextGig.timeIntervalString;
            calloutView.showDetailDisclosureButton = YES;
        } else {
            calloutView.title = venueName;
            calloutView.subtitle = NSLocalizedString(@"map.venue.nomoregigs", @"");
            calloutView.showDetailDisclosureButton = NO;
        }

        calloutViewAnchor = CGPointMake(stageView.center.x, stageView.y);
        if ([venueName isEqualToString:@"Teltta"]) {
            calloutViewAnchor.x += 6;
        } else {
            calloutViewAnchor.x += 2;
        }
        calloutView.frame = CGRectMake(floorf(calloutViewAnchor.x*mapScrollView.zoomScale-calloutView.width/2), floorf(calloutViewAnchor.y*mapScrollView.zoomScale-30-calloutView.height/2), calloutView.width, calloutView.height);

        [self beginFadingAnimationWithDuration:0.4 withView:calloutView];
        calloutView.hidden = NO;

        // NSLog(@"showing callout for stage: %d", stageView.tag);

        stageView.alpha = 1;

        for (UIView *aStageView in stageViews) {
            if (aStageView.alpha > 0 && aStageView != stageView) {
                [self beginFadingAnimationWithDuration:0.4 withView:aStageView];
                aStageView.alpha = 0;
            }
        }

        [UIView commitAnimations];

        CGPoint centerPointInScale = stageView.center;
        // NSLog(@"focusing on point: %f %f", centerPointInScale.x, centerPointInScale.y);
        [self focusOnPoint:centerPointInScale animated:YES ignorePointsOutsideMap:NO];
*/
    } else {

        if (!stageHilightCurtain.hidden) {
            [self beginFadingAnimationWithDuration:0.4 withView:stageHilightCurtain];
            stageHilightCurtain.hidden = YES;
        }

        [self beginFadingAnimationWithDuration:0.4 withView:calloutView];
        calloutView.hidden = YES;

        for (UIView *aStageView in stageViews) {
            if (aStageView.alpha > 0) {
                [self beginFadingAnimationWithDuration:0.8 withView:aStageView];
                aStageView.alpha = 0;
            }
        }

        [UIView commitAnimations];
    }

    selectedStageView = stageView;
}

- (void)hilightAllStages
{
    stageHilightCurtain.hidden = NO;
    for (UIView *aStageView in stageViews) {
        if (aStageView.alpha < 1) {
            aStageView.alpha = 1;
        }
    }
    [self performSelector:@selector(selectStageView:) withObject:nil afterDelay:2];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return mapImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (userLocation != nil) {
        [self updateUserLocationDisplayAnimated:NO];
    }

    calloutView.frame = CGRectMake((int)(calloutViewAnchor.x*mapScrollView.zoomScale-calloutView.width/2), (int)(calloutViewAnchor.y*mapScrollView.zoomScale-30-calloutView.height/2), calloutView.width, calloutView.height);
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // NSLog(@"received location update: %@", newLocation);

    userLocationImageView.hidden = NO;
    locationFailCount = 0;

    if (userLocation == nil) {

        userLocationCalloutView.hidden = NO;

        self.userLocation = newLocation;
        [self updateUserLocationDisplayAnimated:NO];
        [self focusOnUserLocationAnimated:YES];

    } else if (newLocation != nil) {

        if ([self pointWithinMapArea:[self pointFromCoordinate:newLocation.coordinate]] &&
            ![self pointWithinMapArea:[self pointFromCoordinate:oldLocation.coordinate]]) {

            userLocationCalloutView.hidden = NO;
        }

        self.userLocation = newLocation;

        if ([userLocation distanceFromLocation:newLocation] < 100) {
            [self updateUserLocationDisplayAnimated:YES];
        } else {
            [self updateUserLocationDisplayAnimated:NO];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    locationFailCount++;
    if  (locationFailCount >= 3) {
        self.userLocation = nil;
        userLocationImageView.hidden = YES;
        userLocationCalloutView.hidden = YES;
    }
}

@end
