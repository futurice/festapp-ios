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

- (BOOL)reloadResource:(FestResource)resourceId forced:(BOOL)forced  __attribute__((deprecated));
- (RACSignal *)signalForResource:(FestResource)resourceId __attribute__((deprecated));

@property (nonatomic, readonly) RACSignal *newsSignal;
@end
