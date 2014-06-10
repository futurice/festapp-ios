//
//  NewsItem.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "NewsItem.h"

@implementation NewsItem

+ (NewsItem *)newFromJSON:(NSDictionary *)dict
{
    NewsItem *item = [[NewsItem alloc] init];

    item.newsId = dict[@"id"];
    item.title = dict[@"title"];
    item.contentHTML = dict[@"content"]; // TODO: sanitize me
    item.imageURL = [NSURL URLWithString:[NSString stringWithFormat:kResourceImageURLFormat, dict[@"image"]]];
    item.datetime = [NSDate dateWithTimeIntervalSince1970:[dict[@"time"] intValue]];

    return item;
}

@end
