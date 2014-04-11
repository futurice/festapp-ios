//
//  FestDataManager.m
//  FestApp
//
//  Created by Oleg Grenrus on 22/03/14.
//
//

#import "FestDataManager.h"
#import "FestHTTPSessionManager.h"
#import "Gig.h"

@interface FestDataManager()
@property (nonatomic, strong) NSArray *resourceConfig;
@property (nonatomic, strong) NSArray *signals;

- (instancetype)initWithResourceConfig:(NSArray *)resourceConfig;

- (void)loadResource:(FestResource)resourceId;

- (id)transformGigs:(id)gigsJSONValue;
- (id)transformNews:(id)newsJSONValue;
- (id)transformFaq:(id)faqJSONValue;
- (id)transformProgram:(id)programJSONValue;
- (id)transformGeneral:(id)generalJSONValue;
- (id)transformServices:(id)servicesJSONValue;

- (NSString *)contentByResourceName:(NSString *)name type:(NSString *)type;
- (NSString *)pathToResourceByName:(NSString *)name type:(NSString *)type;
@end

@implementation FestDataManager
+ (FestDataManager *)sharedFestDataManager
{
    static FestDataManager *_sharedFestDataManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFestDataManager = [[self alloc]
                                   initWithResourceConfig:@[
                                                            @{
                                                                @"name": kResourceNameBands,
                                                                @"suffix": kResourceTypeSuffix,
                                                                @"url": @"/api/artists",
                                                                @"selector": @"transformGigs:"
                                                                },
                                                            @{
                                                                @"name": kResourceNameNews,
                                                                @"suffix": kResourceTypeSuffix,
                                                                @"url": @"/api/news",
                                                                @"selector": @"transformNews:"
                                                                },
                                                            @{
                                                                @"name": kResourceNameFAQ,
                                                                @"suffix": kResourceTypeSuffix,
                                                                @"url": @"/api/faq",
                                                                @"selector": @"transformFaq:"
                                                                },
                                                            @{
                                                                @"name": kResourceNameNews,
                                                                @"suffix": kResourceTypeSuffix,
                                                                @"url": @"/api/program",
                                                                @"selector": @"transformProgram:"
                                                                },
                                                            @{
                                                                @"name": kResourceNameGeneral,
                                                                @"suffix": kResourceTypeSuffix,
                                                                @"url": @"/api/general",
                                                                @"selector": @"transformGeneral:"
                                                                },
                                                            @{
                                                                @"name": kResourceNameServices,
                                                                @"suffix": kResourceTypeSuffix,
                                                                @"url": @"/api/services",
                                                                @"selector": @"transformServices:"
                                                                },
                                                            @{
                                                                @"name": kResourceNameStages,
                                                                @"suffix": kResourceTypeSuffix,
                                                                @"url": @"/api/stages",
                                                                @"selector": @"transformStages:"
                                                                }
                                                            ]];
    });

    return _sharedFestDataManager;
}

- (instancetype)initWithResourceConfig:(NSArray *)resourceConfig
{
    self = [super init];
    if (self) {
        _resourceConfig = resourceConfig;

        NSMutableArray *signals = [NSMutableArray arrayWithCapacity:kFestResourceCount];
        NSAssert(resourceConfig.count == kFestResourceCount, @"There should be seven resources");

        for (NSUInteger i = 0; i < kFestResourceCount; i++) {
            signals[i] = [RACReplaySubject replaySubjectWithCapacity:2];
        }

        _signals = signals;

        for (NSUInteger i = 0; i < kFestResourceCount; i++) {
            [self loadResource:i];
        }
    }
    return self;
}

# pragma mark - Signals

- (RACSignal *)signalForResource:(FestResource)resourceId
{
    return self.signals[resourceId];
}

# pragma mark - Resource polling

- (BOOL)reloadResource:(FestResource)resourceId forced:(BOOL)forced
{
    NSString *resourceName = self.resourceConfig[resourceId][@"name"];
    NSString *resourceUrl = self.resourceConfig[resourceId][@"url"];
    SEL selector = NSSelectorFromString(self.resourceConfig[resourceId][@"selector"]);
    NSString *suffix = self.resourceConfig[resourceId][@"suffix"];

    NSString *keyForLastUpdated = [NSString stringWithFormat:@"%@%@", kResourceLastUpdatedPrefix, resourceName];

    // Check when we updated gigs last
    if (!forced) {
        NSDate *lastUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:keyForLastUpdated];

        if (lastUpdated && -[lastUpdated timeIntervalSinceNow] < kResourcePollInterval) {
            NSLog(@"%@ are recent enough", resourceName);
            return NO;
        }
    }

    FestHTTPSessionManager *sessionManager = [FestHTTPSessionManager sharedFestHTTPSessionManager];

    // TODO: implement HEAD fetching as well

    [sessionManager GET:resourceUrl parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        (void) task;

        NSLog(@"fetched %@", resourceName);

        // save to file
        NSError *error;

        NSString *path = [self pathToResourceByName:resourceName type:suffix];
        NSData *content = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];

        if (!error) {
            if (![content writeToFile:path options:NSDataWritingAtomic error:&error]) {
                NSLog(@"Error writing updated %@: %@", resourceName, error);
            }
        } else {
            NSLog(@"Error serializing %@: %@", resourceName, error);
        }

        // push into subject
        // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
        IMP imp = [self methodForSelector:selector];
        id (*transform)(id, SEL, id) = (void *)imp;
        id object = transform(self, selector, responseObject);

        RACReplaySubject *subject = (RACReplaySubject *) self.signals[resourceId];
        [subject sendNext: object];

        // store last updated field
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:keyForLastUpdated];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        (void) task;
        NSLog(@"failed to fetch %@: %@", resourceName, error);
    }];

    return YES;
}

# pragma mark - Resource preloading

- (void)loadResource:(FestResource)resourceId
{
    NSString *resourceName = self.resourceConfig[resourceId][@"name"];
    SEL selector = NSSelectorFromString(self.resourceConfig[resourceId][@"selector"]);
    IMP imp = [self methodForSelector:selector];
    id (*transform)(id, SEL, id) = (void *)imp;

    NSString *suffix = self.resourceConfig[resourceId][@"suffix"];

    NSString *resourceDataString = [self contentByResourceName:resourceName type:suffix];
    NSDictionary *resourceJSON = [resourceDataString JSONValue];
    id object = transform(self, selector, resourceJSON);

    RACReplaySubject *subject = (RACReplaySubject *) self.signals[resourceId];
    [subject sendNext: object];
}

#pragma mark - Resource transformers

- (id)transformGigs:(id)gigsJSONValue
{
    return [Gig gigsFromArrayOfDicts:gigsJSONValue];
}

- (id)transformNews:(id)newsJSONValue
{
    NSArray *newsArray = newsJSONValue;
    NSMutableArray *news = [newsArray mutableCopy];

    [news sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
        NSTimeInterval time1 = [dict1[@"time"] doubleValue];
        NSTimeInterval time2 = [dict2[@"time"] doubleValue];
        return (time2 - time1);  // most recent, i.e. bigger time value, will be first. i.e. "smaller"
    }];

    return news;
}

- (id)transformFaq:(id)faqJSONValue
{
    NSArray *faqJSONArray = faqJSONValue;
    return [faqJSONArray lastObject];
}

- (id)transformProgram:(id)programJSONValue
{
    return programJSONValue[0];
}

- (id)transformGeneral:(id)generalJSONValue
{
    return generalJSONValue;
}

- (id)transformServices:(id)servicesJSONValue
{
    return servicesJSONValue;
}

- (id)transformStages:(id)stagesJSONValue
{
    return stagesJSONValue;
}

#pragma mark - Resource storing

- (NSString *)pathToResourceByName:(NSString *)name type:(NSString *)type
{
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [paths[0] stringByAppendingPathComponent:@"Content"];
	NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		if (![fileManager createDirectoryAtPath:path
                    withIntermediateDirectories:NO
                                     attributes:nil
                                          error:&error]) {
			NSLog(@"Create directory error: %@", error);
		}
	}

    return [path stringByAppendingPathComponent:[name stringByAppendingPathExtension:type]];
}

- (NSString *)contentByResourceName:(NSString *)name type:(NSString *)type
{
    NSString *path;
    NSError *error;

    // dynamic resource, let's use the locally saved version if available:
    path = [self pathToResourceByName:name type:type];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:path]) {

        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
        if (sourcePath == nil) {
            return nil;
        }
        BOOL success = [fileManager copyItemAtPath:sourcePath toPath:path error:&error];
        if (!success) {
            NSLog(@"%s: Error writing initial content of \"%@\": %@", __func__, path, error);
            return nil;
        }
    }

    NSStringEncoding enc;
    NSString *content = [NSString
                         stringWithContentsOfFile:path
                         usedEncoding:&enc
                         error:&error];
    if (content) {
        return content;
    } else {
        NSLog(@"Error reading content of \"%@\": %@", path, error);
        return nil;
    }
}
@end
