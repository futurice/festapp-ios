//
//  FestDataManager.h
//  FestApp
//
//  Created by Oleg Grenrus on 22/03/14.
//
//

#import <Foundation/Foundation.h>

@interface FestDataManager : NSObject
+ (FestDataManager *)sharedFestDataManager;

- (BOOL)reloadResource:(FestResource)resourceId forced:(BOOL)forced;
- (RACSignal *)signalForResource:(FestResource)resourceId;
@end
