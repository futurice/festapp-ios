//
//  FestAppAppDelegate.h
//  FestApp
//

#import <UIKit/UIKit.h>

#import "RR14ScheduleViewController.h"
#import "RR14NewsViewController.h"
#import "RR14ArtistsViewController.h"
#import "RR14MapViewController.h"
#import "RR14InfoViewController.h"

#import "Artist.h"
#import "NewsItem.h"
#import "InfoItem.h"

@class InfoViewController;

#define kLogoViewTag 22

@interface FestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButtonItem;

@property (nonatomic, strong) IBOutlet RR14ScheduleViewController *scheduleViewController;
@property (nonatomic, strong) IBOutlet RR14NewsViewController *newsViewController;
@property (nonatomic, strong) IBOutlet RR14ArtistsViewController *artistsViewController;
@property (nonatomic, strong) IBOutlet RR14MapViewController *mapViewController;
@property (nonatomic, strong) IBOutlet RR14InfoViewController *infoViewController;
- (IBAction)goBack:(id)sender;

- (IBAction)showSchedule:(id)sender;
- (IBAction)showNews:(id)sender;
- (IBAction)showArtists:(id)sender;
- (IBAction)showMap:(id)sender;
- (IBAction)showFoodInfo:(id)sender;
- (IBAction)showGeneralInfo:(id)sender;

- (void)showNewsItem:(NewsItem *)newsItem;
- (void)showInfoItem:(InfoItem *)infoItem;
- (void)showArtist:(Artist *)artist;
- (void)showScheduleAt:(Artist *)artist;

@end
