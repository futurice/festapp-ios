//
//  FestHTTPSessionManager.h
//  FestApp
//
//

#import "AFHTTPSessionManager.h"

@interface FestHTTPSessionManager : AFHTTPSessionManager
+ (FestHTTPSessionManager *)sharedFestHTTPSessionManager;
- (instancetype)initWithBaseURL:(NSURL *)url;
@end
