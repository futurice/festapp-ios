//
//  FestImageManager.h
//  FestApp
//
//  Created by Oleg Grenrus on 12/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFHTTPSessionManager.h"

@interface FestImageManager : AFHTTPSessionManager
+ (FestImageManager *)sharedFestImageManager;

- (RACSignal *)imageSignalFor:(NSString *)imagePath;
@end
