//
//  RR14NewsItemViewController.h
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RR14WebContentViewController.h"
#import "NewsItem.h"

@interface RR14NewsItemViewController : RR14WebContentViewController
- (id)initWithNewsItem:(NewsItem *)newsItem;
@end
