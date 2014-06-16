//
//  InfoItem.m
//  FestApp
//
//  Created by Oleg Grenrus on 14/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "InfoItem.h"

@implementation InfoItem
- (instancetype)initFromJSON:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _title = [[dict[@"desc"] stringByReplacingOccurrencesOfString:@"Ruisrock 2014 |" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if ([_title isEqualToString:@"UKK"]) {
            _title = @"Usein kysytyt kysymykset";
        }

        _content = dict[@"content"];
    }
    return self;
}
@end
