//
//  RR14NewsItemViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14NewsItemViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"

@interface RR14NewsItemViewController ()
@property (nonatomic, strong) NewsItem* newsItem;
@end

@implementation RR14NewsItemViewController

#pragma mark - Constructor

- (id)initWithNewsItem:(NewsItem *)newsItem
{
    self = [super initWithContent:newsItem.contentHTML title:newsItem.title];
    if (self) {

    }
    return self;
}

@end
