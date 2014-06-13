//
//  FestRR14ArtistCell.m
//  FestApp
//
//  Created by Oleg Grenrus on 12/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14ArtistCell.h"

#import "FestImageManager.h"

@interface RR14ArtistCell ()
@property (nonatomic, strong) RACDisposable *imageDisposable;
@end

@implementation RR14ArtistCell


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

    // Configure the view for the selected state
}

#pragma mark - setter
- (void)setArtist:(Artist *)artist
{
    if (_artist == artist) {
        return;
    }

    _artist = artist;
    [self.imageDisposable dispose];

    self.nameLabel.text = artist.artistName;

    self.imageDisposable = [[[FestImageManager sharedFestImageManager] imageSignalFor:artist.imagePath withSize:self.artistImageView.frame.size] subscribeNext:^(UIImage *image) {
        self.artistImageView.image = image;
    }];
}

@end
