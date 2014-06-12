//
//  RR14ArtistViewController.h
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Artist.h"

@interface RR14ArtistViewController : UIViewController
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet UIButton *favouriteButton;

@property (nonatomic, strong) IBOutlet UILabel *artistLabel;
@property (nonatomic, strong) IBOutlet UILabel *stageLabel;
@property (nonatomic, strong) IBOutlet UILabel *quoteLabel;

@property (nonatomic, strong) IBOutlet UILabel *membersTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *membersLabel;

@property (nonatomic, strong) IBOutlet UILabel *foundedTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *foundedLabel;

+ (RR14ArtistViewController *) newWithArtist:(NSString *)artist;

- (IBAction)toggleFavourite:(id)sender;
@end
