//
//  RR2014MainViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 09/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR2014MainViewController.h"

#import "FestDataManager.h"

@interface RR2014MainViewController ()

@end

@implementation RR2014MainViewController

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

@end
