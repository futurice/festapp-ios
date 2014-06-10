//
//  FestAppAppDelegate.h
//  FestApp
//

#import <UIKit/UIKit.h>

#import "RR14ScheduleViewController.h"
#import "RR14NewsViewController.h"
#import "RR14ArtistsViewController.h"

#import "InfoViewController.h"
#import "MapViewController.h"
#import "TimelineViewController.h"

@class InfoViewController;

#define kLogoViewTag 22

@interface FestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButtonItem;

@property (nonatomic, strong) IBOutlet RR14ScheduleViewController *scheduleViewController;
@property (nonatomic, strong) IBOutlet RR14NewsViewController *newsViewController;
@property (nonatomic, strong) IBOutlet RR14ArtistsViewController *artistsViewController;

- (IBAction)goBack:(id)sender;

- (IBAction)showSchedule:(id)sender;
- (IBAction)showNews:(id)sender;
- (IBAction)showArtists:(id)sender;

- (void)showNewsItem:(NSString *)newsItemId;
- (void)showArtist:(NSString *)artistId;

// TODO: remove me
@property (nonatomic, strong) IBOutlet InfoViewController *infoViewController;
@property (nonatomic, strong) IBOutlet MapViewController *mapViewController;
@property (nonatomic, strong) IBOutlet TimelineViewController *timelineViewController;

@end
