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
        self.title = [[dict[@"desc"] stringByReplacingOccurrencesOfString:@"Ruisrock 2014 |" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if ([self.title isEqualToString:@"UKK"]) {
            self.title = @"Usein kysytyt kysymykset";
        }

        self.content = dict[@"content"];
    }
    return self;
}
@end
