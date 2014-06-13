//
//  FestFavouritesManager.h
//  FestApp
//
//  Created by Oleg Grenrus on 13/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FestFavouritesManager : NSObject
// NSArray of artistIds
@property (nonatomic, readonly) RACSignal *favouritesSignal;

+ (FestFavouritesManager *)sharedFavouritesManager;

- (void)toggleFavourite:(NSString*)artistId favourite:(BOOL)favourite;
@end
