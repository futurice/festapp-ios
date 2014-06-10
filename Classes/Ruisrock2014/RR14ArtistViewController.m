//
//  RR14ArtistViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14ArtistViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"

@interface RR14ArtistViewController ()
@property (nonatomic, strong) NSString *artistId;
@end

@implementation RR14ArtistViewController

+ (RR14ArtistViewController *)newWithArtistId:(NSString *)artistId
{
    RR14ArtistViewController *controller = [[RR14ArtistViewController alloc] initWithNibName:@"RR14ArtistViewController" bundle:nil];

    // TODO: implement me

    [controller setArtistId:artistId];

    return controller;
}

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

    self.navigationItem.leftBarButtonItem = [APPDELEGATE backBarButtonItem];

    [[self artistLabel] setText:[self artistId]];
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

@end
