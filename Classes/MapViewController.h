//
//  MapViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class CalloutView;

@interface MapViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate> {
    CGPoint calloutViewAnchor;

    NSArray *stageGlowViews;
    UIView *selectedStageView;

    int locationFailCount;

    BOOL firstViewing;
}

@property (strong, nonatomic) IBOutlet UIScrollView *mapScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *mapImageView;
@property (strong, nonatomic) IBOutlet UIImageView *userLocationImageView;
@property (strong, nonatomic) IBOutlet UIView *userLocationCalloutView;
@property (strong, nonatomic) IBOutlet UILabel *userLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *userLocationAccuracyLabel;

@property (strong, nonatomic) IBOutlet UIView *gpsInfoView;
@property (strong, nonatomic) IBOutlet UILabel *gpsInfoLabel;

@property (strong, nonatomic) CalloutView *calloutView;

@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSArray *stageViews;
@property (strong, nonatomic) UIView *stageHilightCurtain;

- (CGPoint)pointFromCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)selectStageView:(UIView *)stageView;
- (void)selectStageView:(UIView *)stageView withHilightCurtain:(BOOL)withHilightCurtain;

@end
