//
//  FestDispatcher.h
//  FestApp
//
//  Created by Oleg Grenrus on 30/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

// Temporary class to break swift-obj-c dependency loop
@interface FestDispatcher : NSObject
+ (FestDispatcher *)sharedFestDispatcher;

// takes anything, not just NewsItem
- (void)showNewsItem:(id)newsItem;
@end
