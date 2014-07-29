//
//  RR2014ScheduleViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestScheduleViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestFavouritesManager.h"

@interface FestScheduleViewController () <TimelineViewDelegate, DayChooserDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UIView *timelineVenuesView;
@property (nonatomic, strong) IBOutlet DayChooser *dayChooser;
@property (nonatomic, strong) IBOutlet TimelineView *timeLineView;
@end

@implementation FestScheduleViewController

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
    self.dayChooser.dayNames = @[@"Friday", @"Saturday"];

    self.timeLineView.delegate = self;

    // gigs
    RACSignal *gigsSignal = FestDataManager.sharedFestDataManager.gigsSignal;
    [gigsSignal subscribeNext:^(id x) {
        self.timeLineView.gigs = x;
    }];

    RACSignal *favouritesSignal = FestFavouritesManager.sharedFavouritesManager.favouritesSignal;
    [favouritesSignal subscribeNext:^(id x) {
        self.timeLineView.favouritedGigs = x;
    }];

    // back button
    self.navigationItem.title = @"";
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

#pragma mark DayChooserDelegate

- (void)dayChooser:(DayChooser *)dayChooser selectedDayWithIndex:(NSUInteger)dayIndex
{
    NSString *currentDay = @"Friday";
    switch (dayIndex) {
        case 0: currentDay = @"Friday"; break;
        case 1: currentDay = @"Saturday"; break;
    }

    self.timeLineView.currentDay = currentDay;
}

#pragma mark TimelineViewDelegate

- (void)timeLineView:(TimelineView *)timeLineView gigSelected:(Gig *)gig
{
    [APPDELEGATE showGig:gig];
}

- (void)timeLineView:(TimelineView *)timeLineView gigFavourited:(Gig *)gig favourite:(BOOL)favourite
{
    FestFavouritesManager *favouriteManager = [FestFavouritesManager sharedFavouritesManager];
    [favouriteManager toggleFavourite:gig favourite:favourite];
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
