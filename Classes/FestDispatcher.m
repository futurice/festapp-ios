//
//  FestDispatcher.m
//  FestApp
//
//  Created by Oleg Grenrus on 30/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestDispatcher.h"
#import "FestAppDelegate.h"

@implementation FestDispatcher
+ (FestDispatcher *)sharedFestDispatcher
{
    static FestDispatcher *_sharedFestDispatcher = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // TODO
        _sharedFestDispatcher = [[self alloc] init];
    });

    return _sharedFestDispatcher;
}

- (void)showNewsItem:(id)newsItem {
    [APPDELEGATE showNewsItem:newsItem];
}
@end
