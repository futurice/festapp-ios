//
//  FestRR14ArtistCell.h
//  FestApp
//
//  Created by Oleg Grenrus on 12/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Artist.h"

@interface RR14ArtistCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *artistImageView;

@property (nonatomic, strong) Artist *artist;
@end
