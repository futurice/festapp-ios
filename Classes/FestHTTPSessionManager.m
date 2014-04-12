//
//  FestHTTPSessionManager.m
//  FestApp
//
//

#import "FestHTTPSessionManager.h"

@implementation FestHTTPSessionManager
+ (FestHTTPSessionManager *)sharedFestHTTPSessionManager
{
    static FestHTTPSessionManager *_sharedFestHTTPSessionManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFestHTTPSessionManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kResourceBaseURL]];
    });

    return _sharedFestHTTPSessionManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];

    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }

    NSOperationQueue *operationQueue = self.operationQueue;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                break;
        }
    }];

    return self;
}
@end
