//
//  FestAppAppDelegate.h
//  FestApp
//

#import <UIKit/UIKit.h>

#import "FestScheduleViewController.h"
#import "FestNewsViewController.h"
#import "FestArtistsViewController.h"
#import "FestMapViewController.h"
#import "FestInfoViewController.h"

#import "Gig.h"

#import "FestApp-Swift.h"

@class InfoViewController;

@interface FestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navController;

@property (nonatomic, strong) IBOutlet FestScheduleViewController *scheduleViewController;
@property (nonatomic, strong) IBOutlet FestNewsViewController *newsViewController;
@property (nonatomic, strong) IBOutlet FestArtistsViewController *gigsViewController;
@property (nonatomic, strong) IBOutlet FestMapViewController *mapViewController;
@property (nonatomic, strong) IBOutlet FestInfoViewController *infoViewController;

- (IBAction)showSchedule:(id)sender;
- (IBAction)showNews:(id)sender;
- (IBAction)showGigs:(id)sender;
- (IBAction)showMap:(id)sender;
- (IBAction)showGeneralInfo:(id)sender;

- (IBAction)showLambdaCalculus:(id)sender;

- (void)showNewsItem:(NewsItem *)newsItem;
- (void)showInfoItem:(InfoItem *)infoItem;
- (void)showGig:(Gig *)gig;

@end
