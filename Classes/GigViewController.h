//
//  GigViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>
#import "WebContentViewController.h"

@class Gig;

@interface GigViewController : WebContentViewController {
    Gig *gig;
}

@property (nonatomic, strong) Gig *gig;

@property (nonatomic, weak) IBOutlet UIImageView *artistImageFrameView;
@property (nonatomic, weak) IBOutlet UIImageView *artistImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *imageLoadingSpinner;
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIButton *youtubeButton;


@property (nonatomic, assign) BOOL shouldFavoriteAllAlternatives;

- (IBAction)favoriteButtonPressed:(UIButton *)button;

@end
