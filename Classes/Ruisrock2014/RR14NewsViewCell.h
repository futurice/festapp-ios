//
//  RR14NewsViewCell.h
//  FestApp
//
//  Created by Oleg Grenrus on 16/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewsItem.h"

@interface RR14NewsViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *datetimeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NewsItem *newsItem;
@end
