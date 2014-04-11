//
//  FestAppAppDelegate.h
//  FestApp
//

#import <UIKit/UIKit.h>

@class InfoViewController;
@class MapViewController;
@class TimelineViewController;
@class NewsViewController;

#define kLogoViewTag 22

@interface FestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) IBOutlet InfoViewController *infoViewController;
@property (nonatomic, strong) IBOutlet MapViewController *mapViewController;
@property (nonatomic, strong) IBOutlet TimelineViewController *timelineViewController;
@property (nonatomic, strong) IBOutlet NewsViewController *newsViewController;

@end
