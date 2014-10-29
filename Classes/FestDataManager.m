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
#import "FestApp-Swift.h"

@interface FestDataManager()
@property (nonatomic, strong) RACSubject *gigsSignal;
@property (nonatomic, strong) RACSubject *newsSignal;
@property (nonatomic, strong) RACSubject *infoSignal;

- (id)preloadResource:(NSString *)name selector:(SEL)selector;
- (BOOL)reloadResource:(NSString *)name path:(NSString *)path selector:(SEL)selector subject:(RACSubject *)subject force:(BOOL)force;

- (id)transformGigs:(id)gigsJSONValue;
- (id)transformNews:(id)newsJSONValue;
- (id)transformInfo:(id)infoJSONValue;

- (NSString *)pathToResourceByName:(NSString *)name;
- (NSString *)contentByResourceName:(NSString *)name;
@end

@implementation FestDataManager

+ (FestDataManager *)sharedFestDataManager
{
    static FestDataManager *_sharedFestDataManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFestDataManager = [[self alloc] init];
    });

    return _sharedFestDataManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // We could use RACBehaviourSubject here, but until loaded we don't have first value!

        // Gigs
        id gigsValue = [self preloadResource:@"gigs" selector:@selector(transformGigs:)];
        RACSubject *gigsSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:gigsValue];
        [self reloadResource:@"gigs" path:FEST_GIGS_JSON_URL selector:@selector(transformGigs:) subject:gigsSubject force:NO];
        _gigsSignal = gigsSubject;

        // News
        id newsValue = [self preloadResource:@"news" selector:@selector(transformNews:)];
        RACSubject *newsSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:newsValue];
        [self reloadResource:@"news" path:FEST_NEWS_JSON_URL selector:@selector(transformNews:) subject:newsSubject force:NO];
        _newsSignal = newsSubject;

        // Info
        id infoValue = [self preloadResource:@"info" selector:@selector(transformInfo:)];
        RACSubject *infoSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:infoValue];
        [self reloadResource:@"info" path:FEST_INFO_JSON_URL selector:@selector(transformInfo:) subject:infoSubject force:NO];
        _infoSignal = infoSubject;
    }
    return self;
}


# pragma mark - Resource polling

- (BOOL)reloadResource:(NSString *)name path:(NSString *)path selector:(SEL)selector subject:(RACSubject *)subject force:(BOOL)force
{
    NSString *keyForLastUpdated = [NSString stringWithFormat:@"%@%@", kResourceLastUpdatedPrefix, name];

    // Check when we updated gigs last
    if (!force) {
        NSDate *lastUpdated = [[NSUserDefaults standardUserDefaults] objectForKey:keyForLastUpdated];

        if (lastUpdated && -[lastUpdated timeIntervalSinceNow] < kResourcePollInterval) {
            NSLog(@"%@ are recent enough", name);
            return NO;
        }
    }

    FestHTTPSessionManager *sessionManager = [FestHTTPSessionManager sharedFestHTTPSessionManager];

    // TODO: implement HEAD fetching as well

    [sessionManager GET:path parameters:@{} success:^(NSURLSessionDataTask *task, id responseObject) {
        (void) task;

        NSLog(@"fetched %@", name);

        // save to file
        NSError *error;

        NSData *content = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];

        if (!error) {
            NSString *filePath = [self pathToResourceByName:name];
            if (![content writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
                NSLog(@"Error writing updated %@: %@", name, error);
            }
        } else {
            NSLog(@"Error serializing %@: %@", name, error);
        }

        // push into subject
        // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
        IMP imp = [self methodForSelector:selector];
        id (*transform)(id, SEL, id) = (void *)imp;
        id object = transform(self, selector, responseObject);

        [subject sendNext: object];

        // store last updated field
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:keyForLastUpdated];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        (void) task;
        NSLog(@"failed to fetch %@: %@", name, error);
    }];

    return YES;
}

# pragma mark - Resource preloading

- (id)preloadResource:(NSString *)name selector:(SEL)selector
{
    IMP imp = [self methodForSelector:selector];
    id (*transform)(id, SEL, id) = (void *)imp;

    NSString *resourceDataString = [self contentByResourceName:name];
    NSDictionary *resourceJSON = [resourceDataString JSONValue];
    id object = transform(self, selector, resourceJSON);

    return object;
}

#pragma mark - Resource transformers

- (id)transformGigs:(id)gigsJSONValue
{
    NSArray *gigsArray = gigsJSONValue;
    NSMutableArray *gigs = [NSMutableArray arrayWithCapacity:gigsArray.count];
    NSUInteger len = [gigsArray count];

    for (NSUInteger idx = 0; idx < len; idx++) {
        NSDictionary *obj = gigsArray[idx];
        Gig *gig = [[Gig alloc] initFromJSON:obj];
        if (gig) {
            [gigs addObject:gig];
        }
    }

    return gigs;
}

- (id)transformNews:(id)newsJSONValue
{
    NSArray *newsArray = newsJSONValue;
    NSMutableArray *news = [NSMutableArray arrayWithCapacity:newsArray.count];
    NSUInteger len = [newsArray count];

    for (NSUInteger idx = 0; idx < len; idx++) {
        NSDictionary *obj = newsArray[idx];
        NewsItem *item = [[NewsItem alloc] initWithDictionary:obj];
        if (item) {
            [news addObject:item];
        }
    }

    [news sortUsingComparator:^NSComparisonResult(NewsItem *a, NewsItem *b) {
        return [b.published compare:a.published];
    }];

    return news;
}

- (id)transformInfo:(id)infoJSONValue
{
    NSArray *infoArray = infoJSONValue;
    NSMutableArray *info = [NSMutableArray arrayWithCapacity:infoArray.count];
    NSUInteger len = [infoArray count];

    for (NSUInteger idx = 0; idx < len; idx++) {
        NSDictionary *obj = infoArray[idx];
        InfoItem *item = [[InfoItem alloc] initWithDictionary:obj];
        if (item) {
            [info addObject:item];
        }
    }

    return info;
}

#pragma mark - Resource storing

- (NSString *)pathToResourceByName:(NSString *)name
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

    return [path stringByAppendingPathComponent:name];
}

- (NSString *)contentByResourceName:(NSString *)name
{
    NSString *path;
    NSError *error;

    // dynamic resource, let's use the locally saved version if available:
    path = [self pathToResourceByName:name];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:path]) {

        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
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
