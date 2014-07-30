//
//  FestArtistCell.m
//  FestApp
//
//  Created by Oleg Grenrus on 12/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestArtistCell.h"

#import "FestImageManager.h"

@interface FestArtistCell ()
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *stageLabel;
@end

@implementation FestArtistCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    if (highlighted) {
        self.nameLabel.textColor = self.stageLabel.textColor = FEST_COLOR_GOLD;
    } else {
        self.nameLabel.textColor = self.stageLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - setter
- (void)setGig:(Gig *)gig
{
    if (_gig == gig) {
        return;
    }

    _gig = gig;
    self.nameLabel.text = gig.gigName;
    self.stageLabel.text = gig.stageAndTimeIntervalString;
}

@end
