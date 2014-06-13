//
//  FestFavouritesManager.m
//  FestApp
//
//  Created by Oleg Grenrus on 13/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestFavouritesManager.h"

#define kFestFavouriteKey @"Favourites"

@interface FestFavouritesManager ()
@property (nonatomic, strong) RACSubject *favouritesSignal;
@end

@implementation FestFavouritesManager
+ (FestFavouritesManager *)sharedFavouritesManager
{
    static FestFavouritesManager *_sharedFestFavouritesManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFestFavouritesManager = [[self alloc] init];
    });

    return _sharedFestFavouritesManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *favourites = [defaults arrayForKey:kFestFavouriteKey];

        self.favouritesSignal = [RACBehaviorSubject behaviorSubjectWithDefaultValue:favourites];
    }
    return self;
}

- (void)toggleFavourite:(Artist *)artist favourite:(BOOL)favourite
{
    if (!artist) {
        NSLog(@"error, toggling favourites without artist");
        return;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *favourites = [defaults arrayForKey:kFestFavouriteKey];
    RACSubject *favouritesSubject = (RACSubject *)self.favouritesSignal;

    if (favourites == nil) {
        favourites = @[];
    }

    NSMutableArray *mutableFavourites = [NSMutableArray arrayWithArray:favourites];
    if (favourite) {
        // add only if not already there
        if (![mutableFavourites containsObject:artist.artistId]) {
            [mutableFavourites addObject:artist.artistId];
        }
    } else {
        // remove while there are objects
        while ([mutableFavourites containsObject:artist.artistId]) {
            [mutableFavourites removeObject:artist.artistId];
        }
    }

    [self toggleNotification:artist favourite:favourite];

    [defaults setObject:mutableFavourites forKey:kFestFavouriteKey];
    [defaults synchronize];

    [favouritesSubject sendNext:mutableFavourites];
}

- (void)toggleNotification:(Artist *)artist favourite:(BOOL)favourite
{
    if (favourite) {
        if ([artist.begin after:[NSDate date]]) {

            NSString *alertText = [NSString stringWithFormat:@"%@\n%@-%@ (%@)", artist.artistName, [artist.begin hourAndMinuteString], [artist.end hourAndMinuteString], artist.venue];

            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            if (localNotif == nil) return;
            localNotif.fireDate = [artist.begin dateByAddingTimeInterval:-kAlertIntervalInMinutes*kOneMinute];
            localNotif.alertBody = alertText;
            localNotif.soundName = @"Riff2.aif";
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];

            NSLog(@"added alert: %@", alertText);
        }

    } else {

        UILocalNotification *notificationToCancel = nil;
        for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
            if([aNotif.alertBody rangeOfString:artist.artistName].location == 0) {
                notificationToCancel = aNotif;
                break;
            }
        }
        if (notificationToCancel != nil) {
            NSLog(@"removed alert: %@", notificationToCancel.alertBody);
            [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
        }
    }
}
@end
