//
//  NewsItem.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "NewsItem.h"

@implementation NewsItem

- (instancetype)initFromJSON:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _newsId = dict[@"id"];
        _title = dict[@"title"];
        _contentHTML = dict[@"content"]; // TODO: sanitize me
        _imagePath = dict[@"image"];
        _datetime = [NSDate dateWithTimeIntervalSince1970:[dict[@"time"] intValue]];
    }
    return self;
}

@end
