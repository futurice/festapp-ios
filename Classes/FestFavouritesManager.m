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

- (void)toggleFavourite:(NSString *)artistId favourite:(BOOL)favourite
{
    if (!artistId) {
        NSLog(@"error, toggling favourites without artistId");
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
        if (![mutableFavourites containsObject:artistId]) {
            [mutableFavourites addObject:artistId];
        }
    } else {
        // remove while there are objects
        while ([mutableFavourites containsObject:artistId]) {
            [mutableFavourites removeObject:artistId];
        }
    }

    [defaults setObject:mutableFavourites forKey:kFestFavouriteKey];
    [defaults synchronize];

    [favouritesSubject sendNext:mutableFavourites];
}
@end
