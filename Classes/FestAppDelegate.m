//
//  FestAppDelegate.m
//  FestApp
//

#import "FestAppDelegate.h"
#import "InfoViewController.h"
#import "MapViewController.h"
#import "TimelineViewController.h"
#import "NavigableContentViewController.h"
#import "NewsViewController.h"
#import "ExternalWebContentViewController.h"
#import "CustomNavigationBar.h"
#import "Gig.h"
#import "NSDate+Additions.h"
#import "UIViewController+Additions.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FestDataManager.h"
#import "AFNetworkActivityIndicatorManager.h"

#import "RR14ArtistViewController.h"
#import "RR14NewsItemViewController.h"

@implementation FestAppDelegate

#pragma mark Application lifecycle

void uncaughtExceptionHandler(NSException *exception);

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    // NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    int favoriteInstructionShownCount = [defaults integerForKey:kFavoritingInstructionShownCounterKey];
    if (favoriteInstructionShownCount < 3) {
        [defaults setBool:NO forKey:kFavoritingInstructionAlreadyShownKey];
        [defaults setInteger:(favoriteInstructionShownCount+1) forKey:kFavoritingInstructionShownCounterKey];
    }

    [defaults synchronize];

    // Navigation bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation-bar.png"] forBarMetrics:UIBarMetricsDefault];

    // Custom back bar button item
    self.backBarButtonItem.target = self;
    self.backBarButtonItem.action = @selector(backAction);


    // Navigation view controller as root
    self.window.rootViewController = self.navController;

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // [mapViewController.locationManager stopUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // TODO: refresh data in festdatamanager?
    // [mapViewController.locationManager startUpdatingLocation];
    // [timelineViewController selectCurrentDayIfViable];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateActive) {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"gig.reminder.title", @"")
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"button.ok", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    [navigationController.navigationBar.topItem.titleView setHidden:YES];

    if (navigationController.viewControllers.count > 1) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 28, 44);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton addTarget:viewController action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        viewController.navigationItem.leftBarButtonItem = backBarButton;
    }
}

#pragma mark - Navigation Actions

- (void)backAction
{
    [self goBack:self];
}

- (IBAction)goBack:(id)sender
{
    [self.navController popViewControllerAnimated:YES];
}

- (IBAction)showSchedule:(id)sender
{
    [self.navController pushViewController:self.scheduleViewController animated:YES];
}

- (IBAction)showNews:(id)sender
{
    [self.navController pushViewController:self.newsViewController animated:YES];
}

- (IBAction)showArtists:(id)sender
{
    [self.navController pushViewController:self.artistsViewController animated:YES];
}

- (void)showNewsItem:(NSString *)newsItemId
{
    UIViewController *controller = [RR14NewsItemViewController newWithNewsItemId:newsItemId];
    [self.navController pushViewController:controller animated:YES];
}

- (void)showArtist:(NSString *)artistId
{
    UIViewController *controller = [RR14ArtistViewController newWithArtistId:artistId];
    [self.navController pushViewController:controller animated:YES];
}

@end
