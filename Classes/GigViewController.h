//
//  GigViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>
#import "WebContentViewController.h"

@class Artist;

@interface GigViewController : WebContentViewController {
    Artist *gig;
}

@property (nonatomic, strong) Artist *gig;

@property (nonatomic, weak) IBOutlet UIImageView *artistImageFrameView;
@property (nonatomic, weak) IBOutlet UIImageView *artistImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *imageLoadingSpinner;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIButton *youtubeButton;
@property (nonatomic, weak) IBOutlet UIButton *spotifyButton;


@property (nonatomic, assign) BOOL shouldFavoriteAllAlternatives;

- (IBAction)favoriteButtonPressed:(UIButton *)button;

- (IBAction)youtubeButtonPressed:(UIButton *)sender;

- (IBAction)spotifyButtonPressed:(UIButton *)sender;

@end
