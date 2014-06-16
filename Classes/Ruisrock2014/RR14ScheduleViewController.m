//
//  RR2014ScheduleViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14ScheduleViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestFavouritesManager.h"

@interface RR14ScheduleViewController ()
@property (nonatomic, strong) IBOutlet UIView *timelineVenuesView;
@end

#define kHourWidth 200
#define kRowHeight 49
#define kTopPadding 45
#define kLeftPadding 80
#define kRowPadding 5

@implementation RR14ScheduleViewController

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
    // Do any additional setup after loading the view from its nib.

    self.dayChooser.delegate = self;
    self.dayChooser.dayNames = @[@"Perjantai", @"Lauantai", @"Sunnuntai"];

    self.timeLineView.delegate = self;

    // artists
    RACSignal *artistsSignal = FestDataManager.sharedFestDataManager.artistsSignal;
    [artistsSignal subscribeNext:^(id x) {
        self.timeLineView.artists = x;
        [self updateVenues:x];
    }];

    RACSignal *favouritesSignal = FestFavouritesManager.sharedFavouritesManager.favouritesSignal;
    [favouritesSignal subscribeNext:^(id x) {
        self.timeLineView.favouritedArtists = x;
    }];

    // back button
    self.navigationItem.leftBarButtonItem = [APPDELEGATE backBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Venues
- (void)updateVenues:(NSArray *)artists
{
    NSMutableArray *venues = [NSMutableArray arrayWithCapacity:6];
    for (Artist *artist in artists) {
        if (![venues containsObject:artist.venue]) {
            [venues addObject:artist.venue];
        }
    }

    // venue labels
    NSUInteger venueCount = venues.count;

    for (NSUInteger venueIdx = 0; venueIdx < venueCount; venueIdx++) {
        NSString *venue = venues[venueIdx];

        CGRect frame = CGRectMake(10, kTopPadding + 10 + kRowHeight * venueIdx, kLeftPadding - 20, kRowHeight - 20);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];

        label.text = venue;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        label.textAlignment = NSTextAlignmentCenter;

        label.font = [UIFont systemFontOfSize:12];

        [self.timelineVenuesView addSubview:label];
    }
}

#pragma mark DaySelection
- (void)selectDay:(NSString *)day
{
    if ([day isEqualToString:@"Perjantai"]) {
        self.dayChooser.selectedDayIndex = 0;
    } else if ([day isEqualToString:@"Lauantai"]) {
        self.dayChooser.selectedDayIndex = 1;
    } else if ([day isEqualToString:@"Sunnuntai"]) {
        self.dayChooser.selectedDayIndex = 2;
    }
}

#pragma mark DayChooserDelegate

- (void)dayChooser:(DayChooser *)dayChooser selectedDayWithIndex:(NSUInteger)dayIndex
{
    NSString *currentDay = @"Perjantai";
    switch (dayIndex) {
        case 0: currentDay = @"Perjantai"; break;
        case 1: currentDay = @"Lauantai"; break;
        case 2: currentDay = @"Sunnuntai"; break;
    }

    self.timeLineView.currentDay = currentDay;
}

#pragma mark TimelineViewDelegate

- (void)timeLineView:(TimelineView *)timeLineView artistSelected:(Artist *)artist
{
    [APPDELEGATE showArtist:artist];
}

- (void)timeLineView:(TimelineView *)timeLineView artistFavourited:(Artist *)artist favourite:(BOOL)favourite
{

}

#pragma mark UIScrollDelegage

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.timelineVenuesView.alpha = 0.5;
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.timelineVenuesView.alpha = 1.0;
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [UIView animateWithDuration:0.3 animations:^{
            self.timelineVenuesView.alpha = 1.0;
        }];
    }
}

@end
