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
@property (nonatomic, strong) IBOutlet UILabel* artistLabel;

+ (RR14ArtistViewController *) newWithArtist:(NSString *)artist;
@end
