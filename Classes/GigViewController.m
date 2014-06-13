//
//  GigViewController.m
//  FestApp
//

#import "GigViewController.h"
#import "Artist.h"
#import "UIViewController+Additions.h"

@interface GigViewController ()

- (void)updateFavoriteButton;

@end

@implementation GigViewController

@synthesize gig;

@synthesize artistImageView;
@synthesize imageLoadingSpinner;
@synthesize favoriteButton;
@synthesize youtubeButton;

@synthesize shouldFavoriteAllAlternatives;


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.scrollView addSubview:self.imageLoadingSpinner];
    [self.scrollView addSubview:self.artistImageView];
    [self.scrollView addSubview:self.artistImageFrameView];
    [self.scrollView addSubview:self.favoriteButton];
    [self.scrollView addSubview:self.youtubeButton];
    [self.scrollView addSubview:self.spotifyButton];
    
    if (!gig.youtubeUrl) {
        [self.youtubeButton setEnabled:false];
    }
    
    if(!gig.spotifyUrl) {
        [self.spotifyButton setEnabled:false];
    }

    self.edgeInsets = UIEdgeInsetsMake(215, 6, 20, 6);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(artistImageLoaded:) name:kNotificationForLoadedArtistImage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(artistImageFailedToLoad:) name:kNotificationForFailedLoadingArtistImage object:nil];

    self.artistImageFrameView.image = [[UIImage imageNamed:@"text_frame"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 40, 40, 40) resizingMode:UIImageResizingModeStretch];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setGig:(Artist *)theGig
{
    if (gig != theGig) {
        gig = theGig;
    }

    [super setWebTitle:gig.artistName subtitle:gig.stageAndTimeIntervalString content:gig.description];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = gig.artistName;

    artistImageView.image = [UIImage imageNamed:@"band-placeholder.png"];

    if (gig.alternativeGigs != nil) {
        NSMutableArray *alternativeGigs = [NSMutableArray arrayWithArray:gig.alternativeGigs];
        [alternativeGigs addObject:gig];
        [alternativeGigs sortUsingFunction:chronologicalGigSort context:nil];
        NSMutableString *stageTimeLabelText = [NSMutableString string];
        for (unsigned int i = 0; i < [alternativeGigs count]; i++) {
            Artist *aGig = alternativeGigs[i];
            [stageTimeLabelText appendString:aGig.stageAndTimeIntervalString];
            if (i < [alternativeGigs count]-1) {
                [stageTimeLabelText appendString:@"\n"];
            }
        }
    }

    [self updateFavoriteButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    [self.tabBarController sendEventToTracker:self.title];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFavoritingInstructionAlreadyShownKey]) {
        [self showAlertWithTitle:nil message:NSLocalizedString(@"gig.reminder.instruction", @"")];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFavoritingInstructionAlreadyShownKey];
    }
}

- (IBAction)favoriteButtonPressed:(UIButton *)button
{
    [self updateFavoriteButton];
}

- (IBAction)youtubeButtonPressed:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:gig.youtubeUrl];
}

- (IBAction)spotifyButtonPressed:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:gig.spotifyUrl];
}

- (void)updateFavoriteButton
{

}

- (void)artistImageLoaded:(NSNotification *)notification
{

}

- (void)artistImageFailedToLoad:(NSNotification *)notification
{
    if ([gig isEqual:notification.object]) {
        [imageLoadingSpinner stopAnimating];
    }
}


@end
