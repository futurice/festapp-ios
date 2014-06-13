//
//  FestDataManager.m
//  FestApp
//
//  Created by Oleg Grenrus on 22/03/14.
//
//

#import "FestDataManager.h"
#import "FestHTTPSessionManager.h"

#import "Artist.h"
#import "NewsItem.h"
#import "InfoItem.h"

@interface FestDataManager()
@property (nonatomic, strong) RACSubject *artistsSignal;
@property (nonatomic, strong) RACSubject *newsSignal;
@property (nonatomic, strong) RACSubject *infoSignal;

- (id)preloadResource:(NSString *)name selector:(SEL)selector;
- (BOOL)reloadResource:(NSString *)name path:(NSString *)path selector:(SEL)selector subject:(RACSubject *)subject force:(BOOL)force;

- (id)transformArtists:(id)artistsJSONValue;
- (id)transformNews:(id)newsJSONValue;
- (id)transformInfo:(id)infoJSONValue;

- (NSString *)pathToResourceByName:(NSString *)name;
- (NSString *)contentByResourceName:(NSString *)name;
@end

@implementation FestDataManager
// TODO: remove me
- (RACSignal *)signalForResource:(FestResource)resourceId
{
    return nil;
}

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

        // Artists
        id artistsValue = [self preloadResource:@"artistit" selector:@selector(transformArtists:)];
        RACSubject *artistsSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:artistsValue];
        [self reloadResource:@"artistit" path:RR_ARTISTS_JSON_URL selector:@selector(transformArtists:) subject:artistsSubject force:NO];
        self.artistsSignal = artistsSubject;

        // News
        id newsValue = [self preloadResource:@"uutiset" selector:@selector(transformNews:)];
        RACSubject *newsSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:newsValue];
        [self reloadResource:@"uutiset" path:RR_NEWS_JSON_URL selector:@selector(transformNews:) subject:newsSubject force:NO];
        self.newsSignal = newsSubject;

        // Info
        id infoValue = [self preloadResource:@"info" selector:@selector(transformInfo:)];
        RACSubject *infoSubject = [RACBehaviorSubject behaviorSubjectWithDefaultValue:infoValue];
        [self reloadResource:@"info" path:RR_INFO_JSON_URL selector:@selector(transformInfo:) subject:infoSubject force:NO];
        self.infoSignal = infoSubject;
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

- (id)transformArtists:(id)artistsJSONValue
{
    return [Artist gigsFromArrayOfDicts:artistsJSONValue];
}

- (id)transformNews:(id)newsJSONValue
{
    NSArray *newsArray = newsJSONValue;
    NSMutableArray *news = [newsArray mutableCopy];
    NSUInteger len = [news count];

    for (NSUInteger idx = 0; idx < len; ) {
        NSDictionary *obj = [news objectAtIndex:idx];
        NewsItem *item = [NewsItem newFromJSON:obj];
        if (item) {
            [news replaceObjectAtIndex:idx withObject:item];
            idx += 1;
        } else {
            [news removeObjectAtIndex:idx];
        }
    }

    [news sortUsingComparator:^NSComparisonResult(NewsItem *a, NewsItem *b) {
        return [b.datetime compare:a.datetime];
    }];

    return news;
}

- (id)transformInfo:(id)infoJSONValue
{
    NSArray *infoArray = infoJSONValue;
    NSMutableArray *info = [NSMutableArray arrayWithCapacity:infoArray.count];
    NSUInteger len = [infoArray count];

    for (NSUInteger idx = 0; idx < len; idx++) {
        NSDictionary *obj = [infoArray objectAtIndex:idx];

        if (![@"kyllä" isEqualToString:obj[@"julkaistu"]]) {
            continue;
        }

        InfoItem *item = [[InfoItem alloc] initFromJSON:obj];
        if (item) {
            [info addObject:item];
        }
    }

    [info sortUsingComparator:^NSComparisonResult(InfoItem *a, InfoItem *b) {
        return [a.title compare:b.title];
    }];

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
