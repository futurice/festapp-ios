//
//  RR2014MainViewController.h
//  FestApp
//
//  Created by Oleg Grenrus on 09/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RR14MainViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *artistImageView;
@property (nonatomic, strong) IBOutlet UILabel *artistLabel;
@property (nonatomic, strong) IBOutlet UILabel *artistSublabel;

@property (nonatomic, strong) IBOutlet UILabel *newsTitleLabel;

- (IBAction)showSchedule:(id)sender;
- (IBAction)showNews:(id)sender;
- (IBAction)showArtists:(id)sender;
- (IBAction)showMap:(id)sender;
- (IBAction)showFoodInfo:(id)sender;
- (IBAction)showGeneralInfo:(id)sender;
- (IBAction)showCurrentNewsItem:(id)sender;
- (IBAction)showCurrentArtist:(id)sender;

@end
