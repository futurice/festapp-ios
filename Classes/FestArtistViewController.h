//
//  FestGigViewController.h
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FestApp-Swift.h"

@interface FestArtistViewController : UIViewController
+ (FestArtistViewController *) newWithGig:(Gig *)gig;
@end
