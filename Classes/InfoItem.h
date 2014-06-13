//
//  InfoItem.h
//  FestApp
//
//  Created by Oleg Grenrus on 14/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoItem : NSObject
- (instancetype)initFromJSON:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@end
