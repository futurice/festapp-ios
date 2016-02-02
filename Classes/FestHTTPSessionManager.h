//
//  FestHTTPSessionManager.h
//  FestApp
//
//

#import <AFNetworking/AFNetworking.h>

@interface FestHTTPSessionManager : AFHTTPSessionManager
+ (FestHTTPSessionManager *)sharedFestHTTPSessionManager;
- (instancetype)initWithBaseURL:(NSURL *)url;
@end
