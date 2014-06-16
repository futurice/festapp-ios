//
//  RR14NewsViewCell.m
//  FestApp
//
//  Created by Oleg Grenrus on 16/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14NewsViewCell.h"

@implementation RR14NewsViewCell

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
- (void)setNewsItem:(NewsItem *)newsItem
{
    if (_newsItem == newsItem) {
        return;
    }

    _newsItem = newsItem;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d.MM.yyyy HH:mm"];

    self.titleLabel.text = newsItem.title;
    self.datetimeLabel.text = [dateFormatter stringFromDate:newsItem.datetime];
    /*
    [self.imageDisposable dispose];



    self.imageDisposable = [[[FestImageManager sharedFestImageManager] imageSignalFor:artist.imagePath withSize:self.artistImageView.frame.size] subscribeNext:^(UIImage *image) {
        self.artistImageView.image = image;
    }];
     */
}

@end
