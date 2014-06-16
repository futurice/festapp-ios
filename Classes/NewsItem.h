//
//  NewsItem.h
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsItem : NSObject
- (instancetype) initFromJSON:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *newsId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *contentHTML;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSDate *datetime;
@end
