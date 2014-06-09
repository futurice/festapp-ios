//
//  FestAppAppDelegate.h
//  FestApp
//

#import <UIKit/UIKit.h>

#import "InfoViewController.h"

#import "MapViewController.h"
#import "TimelineViewController.h"
#import "NewsViewController.h"

@class InfoViewController;

#define kLogoViewTag 22

@interface FestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navController;

@property (nonatomic, strong) IBOutlet InfoViewController *infoViewController;

// TODO: remove me
@property (nonatomic, strong) IBOutlet MapViewController *mapViewController;
@property (nonatomic, strong) IBOutlet TimelineViewController *timelineViewController;
@property (nonatomic, strong) IBOutlet NewsViewController *newsViewController;

@end
