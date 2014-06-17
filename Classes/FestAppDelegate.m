//
//  FestAppDelegate.m
//  FestApp
//

#import "FestAppDelegate.h"

#import "Artist.h"
#import "NSDate+Additions.h"
#import "UIViewController+Additions.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FestDataManager.h"
#import "AFNetworkActivityIndicatorManager.h"

#import "RR14ArtistViewController.h"
#import "RR14NewsItemViewController.h"
#import "RR14WebContentViewController.h"

@interface FestAppDelegate ()

@end

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

    NSInteger favoriteInstructionShownCount = [defaults integerForKey:kFavoritingInstructionShownCounterKey];
    if (favoriteInstructionShownCount < 3) {
        [defaults setBool:NO forKey:kFavoritingInstructionAlreadyShownKey];
        [defaults setInteger:(favoriteInstructionShownCount+1) forKey:kFavoritingInstructionShownCounterKey];
    }

    [defaults synchronize];

    // Navigation bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation-bar.png"] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];

    // Custom back bar button item
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back_arrow.png"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back_arrow.png"]];

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

- (void)showScheduleAt:(Artist *)artist
{
    [self.navController pushViewController:self.scheduleViewController animated:YES];
    [self.scheduleViewController selectDay:artist.day];
}

- (IBAction)showMap:(id)sender
{
    [self.navController pushViewController:self.mapViewController animated:YES];
}

- (IBAction)showFoodInfo:(id)sender
{
    UIViewController *controller = [[RR14WebContentViewController alloc] initWithContent:@"<h1>RUOKAA!!!</h1>" title:nil image:nil];
    [self.navController pushViewController:controller animated:YES];
}

- (IBAction)showGeneralInfo:(id)sender
{
    [self.navController pushViewController:self.infoViewController animated:YES];
}

- (void)showNewsItem:(NewsItem *)newsItem
{
    UIViewController *controller = [[RR14NewsItemViewController alloc] initWithNewsItem:newsItem];
    [self.navController pushViewController:controller animated:YES];
}

- (void)showInfoItem:(InfoItem *)infoItem
{
    UIViewController *controller = [[RR14WebContentViewController alloc] initWithContent:infoItem.content title:infoItem.title image:nil];
    [self.navController pushViewController:controller animated:YES];
}

- (void)showArtist:(Artist *)artist
{
    UIViewController *controller = [RR14ArtistViewController newWithArtist:artist];
    [self.navController pushViewController:controller animated:YES];
}

@end
