//
//  FestAppDelegate.m
//  FestApp
//

#import "FestAppDelegate.h"

#import "Gig.h"
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

- (IBAction)showMap:(id)sender
{
    [self.navController pushViewController:self.mapViewController animated:YES];
}

- (IBAction)showFoodInfo:(id)sender
{
    UIViewController *controller = [RR14WebContentViewController newWithContent:@"<h1>RUOKAA!!!</h1>"];
    [self.navController pushViewController:controller animated:YES];
}

- (IBAction)showGeneralInfo:(id)sender
{
    UIViewController *controller = [RR14WebContentViewController newWithContent:@"<h1>TIETOJA!!!</h1><h2>PALJON</h2>"];
    [self.navController pushViewController:controller animated:YES];
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
