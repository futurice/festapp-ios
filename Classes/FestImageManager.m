//
//  FestImageManager.m
//  FestApp
//
//  Created by Oleg Grenrus on 12/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestImageManager.h"

#import "FestHTTPSessionManager.h"
#import "NSString+MD5.h"

@interface FestImageManager ()
@property (strong, nonatomic) NSString *directory;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSMutableDictionary *signals;
@end

@implementation FestImageManager
+ (FestImageManager *)sharedFestImageManager
{
    static FestImageManager *_sharedFestImageManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFestImageManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:RR_IMAGE_BASE_URL]];
    });

    return _sharedFestImageManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];

    if (self) {
        // response is images
        self.responseSerializer = [AFImageResponseSerializer serializer];

        // operation queue
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

        // signals
        self.signals = [NSMutableDictionary dictionaryWithCapacity:64]; // arbitrary size

        // image directory
        self.fileManager = [NSFileManager defaultManager];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.directory = [paths[0] stringByAppendingPathComponent:@"ArtistImages"];

        NSError *fileError;
        if (![self.fileManager fileExistsAtPath:self.directory]) {
            if (![self.fileManager createDirectoryAtPath:self.directory
                        withIntermediateDirectories:NO
                                         attributes:nil
                                              error:&fileError]) {
                NSLog(@"Create directory error: %@", fileError);
            }
        }
    }

    return self;
}

- (RACSignal *)imageSignalFor:(NSString *)imagePath
{
    RACSignal *signal = self.signals[imagePath];
    if (signal == nil) {
        NSString *md5path = [imagePath MD5];

        NSString *imageName = [NSString stringWithFormat:@"%@.jpg", md5path];
        NSString *imageFilePath = [self.directory stringByAppendingPathComponent:imageName];

        UIImage *artistImage = [UIImage imageNamed:@"news_bg_flowers.png"];
        if ([self.fileManager fileExistsAtPath:imageFilePath]) {
            artistImage = [UIImage imageWithContentsOfFile:imageFilePath];
        }

        // TODO: try cache
        RACSubject *subject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:artistImage];
        signal = subject;

        self.signals[imagePath] = signal;

        [self GET:imagePath parameters:@{} success:^(NSURLSessionDataTask *task, UIImage *image) {
            [subject sendNext:image];

            // save file
            // TODO: make NSData and check an error
            [self.fileManager createFileAtPath:imageFilePath
                                      contents:UIImagePNGRepresentation(image)
                                    attributes:nil];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    return signal;
}
@end
