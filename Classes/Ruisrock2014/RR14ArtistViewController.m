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
    // Do any additional setup after loading the view from its nib.

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

    // Load image
    FestImageManager *imageManager = [FestImageManager sharedFestImageManager];
    [[imageManager imageSignalFor:self.artist.imagePath] subscribeNext:^(UIImage *image) {
        self.imageView.image = image;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    CGRect quoteLabelSize =
    [self.artist.quote boundingRectWithSize:CGSizeMake(self.quoteLabel.frame.size.width, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.quoteLabel.font
                                                                                               }
                                    context:nil];

    self.quoteLabel.frame = CGRectMake(self.quoteLabel.frame.origin.x,
                                       self.quoteLabel.frame.origin.y,
                                       quoteLabelSize.size.width,
                                       quoteLabelSize.size.height + 200);


    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
