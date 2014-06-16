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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d.MM.yyyy HH:mm"];

    NSString *content = [NSString stringWithFormat:@"<p><span class=\"datetime\">%@</span></p>%@", [dateFormatter stringFromDate:newsItem.datetime], newsItem.contentHTML];

    NSURL *imageURL = [NSURL URLWithString:[RR_IMAGE_BASE_URL stringByAppendingString:newsItem.imagePath]];
    self = [super initWithContent:content title:newsItem.title image:imageURL];
    if (self) {

    }
    return self;
}

@end
