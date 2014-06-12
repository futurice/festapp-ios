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

#import "NewsItem.h"

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
    RACSignal *intervalSignal = [RACSignal interval:20 onScheduler:[RACScheduler mainThreadScheduler]];;
    RACBehaviorSubject *intervalSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:[NSDate date]];
    [intervalSignal subscribeNext:^(id x) {
        [intervalSubject sendNext:x];
    }];

    RACSignal *artistsSignal = FestDataManager.sharedFestDataManager.artistsSignal;
    RACSignal *currentArtistSignal =
    [RACSignal combineLatest:@[intervalSubject, artistsSignal]
                    reduce:^id(NSDate *date, NSArray *artists) {
                        NSUInteger idx = (NSUInteger)([date timeIntervalSinceReferenceDate] * 1000) % MAX(artists.count, 1);
                        return artists[idx];
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

    // No back text
    self.navigationItem.backBarButtonItem.title = @"foo";
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
    [APPDELEGATE showArtists:sender];
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
    [APPDELEGATE showArtist:self.currentArtist];
}

- (IBAction)showCurrentNewsItem:(id)sender
{
    NSLog(@"show current news item");
    [APPDELEGATE showNewsItem:self.currentNewsItem];
}



@end
