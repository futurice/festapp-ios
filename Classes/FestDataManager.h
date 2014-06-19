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

@property (nonatomic, readonly) RACSignal *artistsSignal;
@property (nonatomic, readonly) RACSignal *newsSignal;
@property (nonatomic, readonly) RACSignal *infoSignal;
@property (nonatomic, readonly) RACSignal *foodSignal;
@end
