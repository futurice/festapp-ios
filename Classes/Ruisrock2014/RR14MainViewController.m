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

@interface RR14MainViewController ()

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

    // Subscribe
    RACSignal *newsSignal = [FestDataManager.sharedFestDataManager signalForResource:FestResourceNews];
    [newsSignal subscribeNext:^(NSArray *news) {
        NSAssert(news.count >= 0, @"We assume there is at least one news entry") ;

        self.newsTitleLabel.text = [((NSDictionary *)[news firstObject]) objectForKey:@"title"];
    }];
    // Do any additional setup after loading the view from its nib.

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
    [APPDELEGATE showArtist:@"Lily Allen"];
}

- (IBAction)showCurrentNewsItem:(id)sender
{
    NSLog(@"show current news item");
    [APPDELEGATE showNewsItem:@"News item: foobar"];
}



@end
