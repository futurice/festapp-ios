//
//  RR2014MainViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 09/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestMainViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestFavouritesManager.h"

#import "NewsItem.h"

#define kUpdateInterval 30

#define kNextInterval 3600

@interface RandomDate : NSObject
@property (nonatomic, readonly, strong) NSDate *date;
@property (nonatomic, readonly, assign) NSUInteger random;

- (instancetype)initWithRandom:(NSUInteger)random date:(NSDate *)date;
@end

@implementation RandomDate
- (instancetype)initWithRandom:(NSUInteger)random date:(NSDate *)date
{
    self = [super init];
    if (self) {
        _random = random;
        _date = date;
    }
    return self;
}
@end

@interface FestMainViewController ()
@property (nonatomic, strong) NewsItem *currentNewsItem;
@property (nonatomic, strong) Gig *currentGig;

@property (nonatomic, strong) IBOutlet UIImageView *gigImageView;
@property (nonatomic, strong) IBOutlet UILabel *gigLabel;
@property (nonatomic, strong) IBOutlet UILabel *gigSublabel;

@property (nonatomic, strong) IBOutlet UILabel *newsTitleLabel;

- (IBAction)showSchedule:(id)sender;
- (IBAction)showNews:(id)sender;
- (IBAction)showGigs:(id)sender;
- (IBAction)showMap:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)showLC:(id)sender;
@end

@implementation FestMainViewController

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

    // Gig

    // Poor man random signal updated at the interval
    RACSignal *intervalSignal =
    [[[[RACSignal interval:kUpdateInterval onScheduler:[RACScheduler mainThreadScheduler]] startWith:[NSDate date]]
      scanWithStart:[[RandomDate alloc] initWithRandom:arc4random() date:[NSDate date]]
      reduce:^id(RandomDate *rd, NSDate *now) {
         NSUInteger r = (1103515245 * rd.random + 12345) % 0x100000000;
         return [[RandomDate alloc] initWithRandom:r date:now];
     }] replayLast];

    RACSignal *gigsSignal = FestDataManager.sharedFestDataManager.gigsSignal;
    RACSignal *favouritesSignal = FestFavouritesManager.sharedFavouritesManager.favouritesSignal;

    RACSignal *currentGigSignal =
    [[RACSignal combineLatest:@[intervalSignal, gigsSignal, favouritesSignal]
                      reduce:^id(RandomDate *rd, NSArray *gigs, NSArray *favourites) {
                          // if there is favourites, pick one from that list
                          Gig *nextGig = nil;
                          for (Gig *gig in gigs) {
                              if ([gig.begin after:rd.date]) {
                                  if (nextGig == nil) {
                                      nextGig = gig;
                                  } else if ([gig.begin before:nextGig.begin]) {
                                      nextGig = gig;
                                  }
                              }
                          }

                          // If less than interval to the beginning of the gig
                          // show it!
                          if (nextGig && [nextGig.begin timeIntervalSinceDate:rd.date] < kNextInterval) {
                              return nextGig;
                          }

                          if (favourites.count != 0) {
                              NSString *gigId = favourites[rd.random % favourites.count];
                              NSUInteger gigIdx = [gigs indexOfObjectPassingTest:^BOOL(Gig* art, NSUInteger idx, BOOL *stop) {
                                  return [art.gigId isEqualToString:gigId];
                              }];

                              if (gigIdx != NSNotFound) {
                                  return gigs[gigIdx];
                              }
                          }

                          // fallback, return random gig
                          NSUInteger randomIdx = rd.random % MAX(gigs.count, 1);
                          return gigs[randomIdx];
                      }] replayLast];

    [currentGigSignal subscribeNext:^(Gig *gig) {
        self.currentGig = gig;

        self.gigLabel.text = gig.gigName;
        self.gigSublabel.text = gig.stageAndTimeIntervalString;
    }];

    RACSignal *imageSignal = [[currentGigSignal map:^id(Gig *gig) {
        return [[FestImageManager sharedFestImageManager] imageSignalFor:gig.imagePath];
    }] switchToLatest];

    [imageSignal subscribeNext:^(UIImage *image) {
        if (image) {
            self.gigImageView.image = image;
        }
    }];

    RACSignal *newsSignal = FestDataManager.sharedFestDataManager.newsSignal;
    [newsSignal subscribeNext:^(NSArray *news) {
        if (news.count > 0) {
            self.newsTitleLabel.text = ((NewsItem *) news[0]).title;
        }
    }];

    // No back text
    self.navigationItem.title = @"";
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

- (IBAction)showGigs:(id)sender
{
    NSLog("@show gigs");
    [APPDELEGATE showGigs:sender];
}

- (IBAction)showMap:(id)sender
{
    NSLog("@show map");
    [APPDELEGATE showMap:sender];
}

- (IBAction)showLC:(id)sender
{
    NSLog(@"show lambda calculus");
    [APPDELEGATE showLambdaCalculus:sender];
}

- (IBAction)showInfo:(id)sender
{
    NSLog("@show general info");
    [APPDELEGATE showGeneralInfo:sender];
}

@end
