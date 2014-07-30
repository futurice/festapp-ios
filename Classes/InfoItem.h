//
//  InfoItem.h
//  FestApp
//
//  Created by Oleg Grenrus on 14/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoItem : NSObject
- (instancetype)initFromJSON:(NSDictionary *)json;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *content;
@end
