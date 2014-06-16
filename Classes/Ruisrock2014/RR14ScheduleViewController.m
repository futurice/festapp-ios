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

@end

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

@end
