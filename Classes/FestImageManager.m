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
@property (strong, nonatomic) NSCache *signals;
@end

@implementation FestImageManager
+ (FestImageManager *)sharedFestImageManager
{
    static FestImageManager *_sharedFestImageManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // TODO
        _sharedFestImageManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:@""]];
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
        _signals = [[NSCache alloc] init]; // arbitrary size

        // image directory
        _fileManager = [NSFileManager defaultManager];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _directory = [paths[0] stringByAppendingPathComponent:@"GigImages"];

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
    return [self imageSignalFor:imagePath withSize:CGSizeZero];
}

- (RACSignal *)imageSignalFor:(NSString *)imagePath withSize:(CGSize)size
{
    UIImage *image = [UIImage imageNamed:imagePath];
    if (!image) {
        image = [UIImage imageNamed:@"artist-placeholder.jpg"];
    }

    if (size.width > 0 && size.height > 0) {
        image = [FestImageManager imageWithImage:image scaledToSize:size];
    }

    RACSubject *subject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:image];

    return subject;
}

#pragma mark - Utilities

// Scale to fill
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    if (newSize.width <= 0.f || newSize.height <= 0.f) {
        return image;
    }
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);

    CGFloat k = MAX(newSize.width / image.size.width, newSize.height / image.size.height);
    CGFloat w = image.size.width * k;
    CGFloat h = image.size.height * k;
    CGFloat x = (newSize.width - w) / 2;
    CGFloat y = (newSize.height - h) / 2;

    [image drawInRect:CGRectMake(x, y, w, h)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
