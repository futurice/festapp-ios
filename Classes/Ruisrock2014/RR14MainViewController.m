//
//  RR2014MainViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 09/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14MainViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestFavouritesManager.h"

#import "NewsItem.h"

#define kUpdateInterval 30

@interface RR14MainViewController ()
@property (nonatomic, strong) NewsItem *currentNewsItem;
@property (nonatomic, strong) Artist *currentArtist;
@end

@implementation RR14MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // News
    RACSignal *newsSignal = FestDataManager.sharedFestDataManager.newsSignal;
    [newsSignal subscribeNext:^(NSArray *news) {
        NSAssert(news.count >= 0, @"We assume there is at least one news entry") ;

        self.currentNewsItem = news.firstObject;
        self.newsTitleLabel.text = self.currentNewsItem.title;
    }];

    // Artist

    // Poor man random signal updated at the interval
    RACSignal *intervalSignal =
    [[[[RACSignal interval:kUpdateInterval onScheduler:[RACScheduler mainThreadScheduler]] startWith:nil]
     scanWithStart:@(arc4random())
     reduce:^id(NSNumber *running, id unused) {
            return @((1103515245 * running.unsignedIntegerValue + 12345) % 0x100000000);
     }] replayLast];

    RACSignal *artistsSignal = FestDataManager.sharedFestDataManager.artistsSignal;
    RACSignal *favouritesSignal = FestFavouritesManager.sharedFavouritesManager.favouritesSignal;

    RACSignal *currentArtistSignal =
    [RACSignal combineLatest:@[intervalSignal, artistsSignal, favouritesSignal]
                      reduce:^id(NSNumber *number, NSArray *artists, NSArray *favourites) {
                          // if there is favourites, pick one from that list
                          if (favourites.count != 0) {
                              NSString *artistId = favourites[number.unsignedIntegerValue % favourites.count];
                              NSUInteger artistIdx = [artists indexOfObjectPassingTest:^BOOL(Artist* art, NSUInteger idx, BOOL *stop) {
                                  return [art.artistId isEqualToString:artistId];
                              }];

                              if (artistIdx != NSNotFound) {
                                  return artists[artistIdx];
                              }
                          }

                          // fallback, return random artist
                          NSUInteger randomIdx = number.unsignedIntegerValue % MAX(artists.count, 1);
                          return artists[randomIdx];
                      }];

    [currentArtistSignal subscribeNext:^(Artist *artist) {
        self.currentArtist = artist;

        self.artistLabel.text = artist.artistName;
        self.artistSublabel.text = artist.stageAndTimeIntervalString;
    }];

    RACSignal *imageSignal = [[currentArtistSignal map:^id(Artist *artist) {
        return [[FestImageManager sharedFestImageManager] imageSignalFor:artist.imagePath];
    }] switchToLatest];

    [imageSignal subscribeNext:^(UIImage *image) {
        self.artistImageView.image = image;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)showSchedule:(id)sender
{
    NSLog(@"show schedule");
    [APPDELEGATE showSchedule:sender];
}

- (IBAction)showNews:(id)sender
{
    NSLog(@"show news");
    [APPDELEGATE showNews:sender];
}

- (IBAction)showArtists:(id)sender
{
    NSLog("@show artists");
    [APPDELEGATE showScheduleAt:self.currentArtist];
}

- (IBAction)showMap:(id)sender
{
    NSLog("@show map");
    [APPDELEGATE showMap:sender];
}

- (IBAction)showFoodInfo:(id)sender
{
    NSLog(@"show food info");
    [APPDELEGATE showFoodInfo:sender];
}

- (IBAction)showGeneralInfo:(id)sender
{
    NSLog("@show general info");
    [APPDELEGATE showGeneralInfo:sender];
}

- (IBAction)showCurrentArtist:(id)sender
{
    NSLog(@"show current artist");
    [APPDELEGATE showScheduleAt:self.currentArtist];
}

- (IBAction)showCurrentNewsItem:(id)sender
{
    NSLog(@"show current news item");
    [APPDELEGATE showNews:sender];
}



@end
