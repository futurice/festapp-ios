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

@property (nonatomic, readonly) RACSignal *festivalSignal;
@property (nonatomic, readonly) RACSignal *gigsSignal;
@property (nonatomic, readonly) RACSignal *newsSignal;
@property (nonatomic, readonly) RACSignal *infoSignal;
@end
