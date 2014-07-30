//
//  FestNewsItemViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestNewsItemViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"

@interface FestNewsItemViewController ()

@end

@implementation FestNewsItemViewController

#pragma mark - Constructor

- (id)initWithNewsItem:(NewsItem *)newsItem
{
    self = [super initWithContent:newsItem.content title:newsItem.title];
    if (self) {

    }
    return self;
}

@end
