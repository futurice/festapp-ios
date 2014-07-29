//
//  FestGigViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestArtistViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"
#import "FestImageManager.h"
#import "FestFavouritesManager.h"

#import "UIView+XYWidthHeight.h"

@interface FestArtistViewController ()
@property (nonatomic, strong) Gig *gig;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UIButton *favouriteButton;

@property (nonatomic, strong) IBOutlet UILabel *gigLabel;
@property (nonatomic, strong) IBOutlet UILabel *stageLabel;
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) IBOutlet UIButton *wikipediaButton;

- (IBAction)toggleFavourite:(id)sender;
- (IBAction)openWikipedia:(id)sender;
@end

@implementation FestArtistViewController

+ (instancetype)newWithGig:(Gig *)gig
{
    FestArtistViewController *controller = [[FestArtistViewController alloc] initWithNibName:@"FestArtistViewController" bundle:nil];

    // TODO: implement me

    controller.gig = gig;

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

    self.navigationItem.title = @"";

    self.gigLabel.text = self.gig.gigName;
    self.stageLabel.text = self.gig.stageAndTimeIntervalString;
    self.infoLabel.text = self.gig.info;

    // Favourite
    [self.favouriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateSelected];

    [self.favouriteButton setTitle:@"Star" forState:UIControlStateNormal];
    [self.favouriteButton setTitle:@"Starred" forState:UIControlStateSelected];

    FestFavouritesManager *favouriteManager = [FestFavouritesManager sharedFavouritesManager];
    [favouriteManager.favouritesSignal subscribeNext:^(NSArray *favourites) {
        BOOL favourited = [favourites containsObject:self.gig.gigId];
        self.favouriteButton.selected = favourited;
    }];

    // Load image
    FestImageManager *imageManager = [FestImageManager sharedFestImageManager];
    [[imageManager imageSignalFor:self.gig.imagePath] subscribeNext:^(UIImage *image) {
        self.imageView.image = image;
    }];

    // wikipedia button
    if (self.gig.wikipediaUrl == nil) {
        self.wikipediaButton.hidden = YES;
    }
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

#pragma mark - Actions

- (IBAction)toggleFavourite:(id)sender
{
    FestFavouritesManager *favouriteManager = [FestFavouritesManager sharedFavouritesManager];
    [favouriteManager toggleFavourite:self.gig favourite:!self.favouriteButton.selected];
}

- (IBAction)openWikipedia:(id)sender
{
    [UIApplication.sharedApplication openURL:self.gig.wikipediaUrl];
}
@end
