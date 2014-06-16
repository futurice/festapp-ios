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
#import "FestImageManager.h"
#import "FestFavouritesManager.h"

#import "UIView+XYWidthHeight.h"

@interface RR14ArtistViewController ()
@property (nonatomic, strong) Artist *artist;
@end

@implementation RR14ArtistViewController

+ (RR14ArtistViewController *)newWithArtist:(Artist *)artist
{
    RR14ArtistViewController *controller = [[RR14ArtistViewController alloc] initWithNibName:@"RR14ArtistViewController" bundle:nil];

    // TODO: implement me

    controller.artist = artist;

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

    self.navigationItem.leftBarButtonItem = [APPDELEGATE backBarButtonItem];

    self.artistLabel.text = self.artist.artistName;
    self.stageLabel.text = self.artist.stageAndTimeIntervalString;
    self.quoteLabel.text = self.artist.quote;

    if (self.artist.members.length == 0) {
        self.membersTitleLabel.text = self.membersLabel.text = @"";
    } else {
        self.membersLabel.text = self.artist.members;
    }

    if (self.artist.founded.length == 0) {
        self.foundedTitleLabel.text = self.foundedLabel.text = @"";
    } else {
        self.foundedLabel.text = self.artist.founded;
    }

    // Favourite
    [self.favouriteButton setImage:[UIImage imageNamed:@"schedule_favourite_selected.png"] forState:UIControlStateSelected];

    [self.favouriteButton setTitle:@"Merkitse suosikiksi" forState:UIControlStateNormal];
    [self.favouriteButton setTitle:@"Merkitty suosikiksi" forState:UIControlStateSelected];

    [self.favouriteButton setTitleColor:RR_COLOR_DARKGREEN forState:UIControlStateNormal];
    [self.favouriteButton setTitleColor:RR_COLOR_LIGHTGREEN forState:UIControlStateSelected];

    FestFavouritesManager *favouriteManager = [FestFavouritesManager sharedFavouritesManager];
    [favouriteManager.favouritesSignal subscribeNext:^(NSArray *favourites) {
        BOOL favourited = [favourites containsObject:self.artist.artistId];
        self.favouriteButton.selected = favourited;
        self.favouriteButton.backgroundColor = favourited ? RR_COLOR_DARKGREEN : RR_COLOR_LIGHTGREEN;
    }];

    // Load image
    FestImageManager *imageManager = [FestImageManager sharedFestImageManager];
    [[imageManager imageSignalFor:self.artist.imagePath] subscribeNext:^(UIImage *image) {
        self.imageView.image = image;
    }];

    // youtube & spotify buttons
    if (self.artist.spotifyUrl == nil && self.artist.youtubeUrl == nil) {
        [self.spotifyButton removeFromSuperview];
        [self.youtubeButton removeFromSuperview];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonRibbon attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.favouriteButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];

    } else if (self.artist.youtubeUrl == nil) {
        [self.youtubeButton removeFromSuperview];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonRibbon attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.spotifyButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    } else if (self.artist.spotifyUrl == nil) {
        [self.spotifyButton removeFromSuperview];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonRibbon attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.youtubeButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.favouriteButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.youtubeButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:58.0]];
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
    [favouriteManager toggleFavourite:self.artist favourite:!self.favouriteButton.selected];
}

- (IBAction)openSpotify:(id)sender
{
    BOOL opened = [UIApplication.sharedApplication openURL:self.artist.spotifyUrl];
    if (!opened) {
        NSString *url = [self.artist.spotifyUrl description];
        NSString *openSpotifyUrl = [[url stringByReplacingOccurrencesOfString:@":" withString:@"/"] stringByReplacingOccurrencesOfString:@"spotify/" withString:@"http://open.spotify.com/"];
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:openSpotifyUrl]];
    }
}

- (void)openYoutube:(id)sender
{
    [UIApplication.sharedApplication openURL:self.artist.youtubeUrl];
}
@end
