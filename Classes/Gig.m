//
//  Gig.m
//  FestApp
//

#import "Gig.h"
#import "NSDate+Additions.h"
#import <CoreLocation/CoreLocation.h>

#import "AFNetworking.h"
#import "FestHTTPSessionManager.h"

@interface Gig () {
    BOOL loadingImage;
}

@end

@implementation Gig

@synthesize artistId;
@synthesize artistName;
@synthesize artistNameForTimelineDisplay;
@synthesize country;
@synthesize date;
@synthesize begin;
@synthesize end;
@synthesize venue;
@synthesize descriptionHTML;
@synthesize imageURL;
@synthesize alternativeGigs;
@synthesize spotifyUrl;
@synthesize youtubeUrl;

@dynamic image;
@dynamic isLoadingArtistImage;
@dynamic hasLoadedArtistImage;
@dynamic timeIntervalString;
@dynamic stageAndTimeIntervalString;
@dynamic duration;
@dynamic favorite;

NSInteger alphabeticalGigSort(id gig1, id gig2, void *context)
{
    NSString *artist1 = [(Gig *) gig1 artistName];
    NSString *artist2 = [(Gig *) gig2 artistName];
    return [artist1 compare:artist2 options:NSCaseInsensitiveSearch];
}

NSInteger chronologicalGigSort(id gig1, id gig2, void *context)
{
    NSDate *begin1 = [(Gig *) gig1 begin];
    NSDate *begin2 = [(Gig *) gig2 begin];
    return [begin1 compare:begin2];
}

+ (NSArray *)gigsFromArrayOfDicts:(NSArray *)dicts
{
	NSMutableArray *gigs = [NSMutableArray arrayWithCapacity:[dicts count]];

    NSDictionary *delimitedArtists = [NSDictionary dictionaryWithContentsOfFile:
                                      [[NSBundle mainBundle] pathForResource:@"ArtistsDelimited" ofType:@"plist"]];

    NSUInteger gigCount = [dicts count];
    NSLog(@"parsing %d gigs", gigCount);

	for (NSUInteger i = 0; i < gigCount; i++) {

        NSDictionary *dict = dicts[i];

		Gig *gig            = [[Gig alloc] init];
		gig.artistId        = [NSString cast:dict[@"id"]];
		gig.artistName      = [NSString cast:dict[@"name"]];
		gig.venue           = [[NSString cast:dict[@"stage"]] capitalizedString];
        gig.descriptionHTML = [NSString cast:dict[@"content"]];
        
        NSString *spotifyUrlStr = [NSString cast:dict[@"spotify"]];
        if([spotifyUrlStr length] != 0) {
            gig.spotifyUrl = [NSURL URLWithString:spotifyUrlStr];
        }
        
        NSString *youtubeUrlStr = [NSString cast:dict[@"youtube"]];
        if([youtubeUrlStr length] != 0) {
            gig.youtubeUrl = [NSURL URLWithString:youtubeUrlStr];
        }

        NSString *imagePath = [NSString cast:dict[@"picture"]];
        if (imagePath) {
            gig.imageURL = [NSURL URLWithString:[NSString stringWithFormat:kResourceImageURLFormat, imagePath]];
        }

        NSScanner *scanner = [NSScanner scannerWithString:gig.artistName];
        NSString *text = nil;

        while ([scanner isAtEnd] == NO) {
            [scanner scanUpToString:@"(" intoString:NULL];
            [scanner scanUpToString:@")" intoString:&text];

            if (text != nil) {
                gig.country = [text substringFromIndex:1];  // omit the (
                gig.artistName = [gig.artistName stringByReplacingOccurrencesOfString:gig.country withString:gig.country.uppercaseString];
            }
        }

        gig.artistNameForTimelineDisplay = [[delimitedArtists valueForKey:gig.artistName] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];

        if (gig.artistNameForTimelineDisplay == nil) {
            gig.artistNameForTimelineDisplay = [gig.artistName stringByReplacingOccurrencesOfString:@"&" withString:@"&\n"];
        }

        NSTimeInterval begin = [dict[@"time_start"] doubleValue];
        NSTimeInterval end   = [dict[@"time_stop"] doubleValue];

        if (begin > 0 && end > 0 && gig.venue != nil && ![gig.venue isEqual:[NSNull null]]) {

            gig.begin = [NSDate dateWithTimeIntervalSince1970:begin];
            gig.end = [NSDate dateWithTimeIntervalSince1970:end];

            // Taking into account the magical year 2103 summer gig:
            if ([gig.end timeIntervalSinceDate:gig.begin] > 24 * kOneHour) {
                gig.end = [gig.begin dateByAddingTimeInterval:(2 * kOneHour)];
            }

           // NSLog(@"%@ %@ - %@", gig.artistName, gig.begin, gig.end);

            NSTimeInterval timeInterval = floor(-kOneHour*[gig.begin hourValueWithDayDelimiterHour:6]);
            if (((int)timeInterval)%10 != 0) {
                timeInterval -= ((int)timeInterval)%10;
            }
            gig.date = [gig.begin dateByAddingTimeInterval:timeInterval];
            // NSLog(@"%f %@", timeInterval, gig.artistName);

            NSString *favoriteKey = [NSString stringWithFormat:@"isFavorite_%@", gig.artistId];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            gig.favorite = [defaults boolForKey:favoriteKey];

            for (Gig *existingGig in gigs) {

                if ([existingGig.artistName isEqualToString:gig.artistName]) {

                    if (existingGig.alternativeGigs == nil) {
                        existingGig.alternativeGigs = [NSMutableArray array];
                    }
                    [existingGig.alternativeGigs addObject:gig];

                    if (gig.alternativeGigs == nil) {
                        gig.alternativeGigs = [NSMutableArray array];
                    }
                    [gig.alternativeGigs addObject:existingGig];
                }
            }

            [gigs addObject:gig];
        }
	}
	return gigs;
}

- (BOOL)isFavorite
{
    return favorite;
}

- (void)setFavorite:(BOOL)isFavorite
{
    favorite = isFavorite;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *favoriteKey = [NSString stringWithFormat:@"isFavorite_%@", artistId];

    if (favorite != [defaults boolForKey:favoriteKey]) {

        if (favorite) {

            if ([begin after:[NSDate date]]) {

                NSString *alertText = [NSString stringWithFormat:@"%@\n%@-%@ (%@)", artistName, [begin hourAndMinuteString], [end hourAndMinuteString], venue];

                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif == nil) return;
                localNotif.fireDate = [begin dateByAddingTimeInterval:-kAlertIntervalInMinutes*kOneMinute];
                localNotif.alertBody = alertText;
                localNotif.soundName = @"Riff2.aif";
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];

                NSLog(@"added alert: %@", alertText);
            }

        } else {

            UILocalNotification *notificationToCancel = nil;
            for (UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
                if([aNotif.alertBody rangeOfString:artistName].location == 0) {
                    notificationToCancel = aNotif;
                    break;
                }
            }
            if (notificationToCancel != nil) {
                NSLog(@"removed alert: %@", notificationToCancel.alertBody);
                [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
            }
        }

        [defaults setBool:favorite forKey:favoriteKey];
        [defaults synchronize];
    }
}

- (BOOL)isLoadingArtistImage
{
    return loadingImage;
}

- (BOOL)hasLoadedArtistImage
{
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [paths[0] stringByAppendingPathComponent:@"ArtistImages"];
    NSString *imageName = [NSString stringWithFormat:@"artistimg_%@.jpg", artistId];
    path = [path stringByAppendingPathComponent:imageName];

    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (UIImage *)image
{
    NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [paths[0] stringByAppendingPathComponent:@"ArtistImages"];
	NSError *fileError;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:path]) {
		if (![fileManager createDirectoryAtPath:path
                    withIntermediateDirectories:NO
                                     attributes:nil
                                          error:&fileError]) {
			NSLog(@"Create directory error: %@", fileError);
		}
	}

    NSString *imageName = [NSString stringWithFormat:@"artistimg_%@.jpg", artistId];
    path = [path stringByAppendingPathComponent:imageName];

    if (![fileManager fileExistsAtPath:path] && !loadingImage) {
        CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:kDistanceFromFestKey];
        BOOL isWifi = [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
        if (distance > 0 && distance < 1000 && isWifi) {
            // Okay, we're in the area, let's not load the images now.
            return nil;
        }

        NSLog(@"loading %@", self.imageURL);

        FestHTTPSessionManager *httpManager = [FestHTTPSessionManager sharedFestHTTPSessionManager];

        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];

        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        requestOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Loaded image: %@", self.imageURL);

            loadingImage = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForLoadedArtistImage object:self];

            NSURL *URL = [NSURL fileURLWithPath:path];
            NSError *error = nil;
            [URL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
            if (error) {
                NSLog(@"error excluding from backup: %@", error);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Image error: %@", error);
            loadingImage = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForFailedLoadingArtistImage object:self];
        }];

        [httpManager.operationQueue addOperation:requestOperation];

        NSLog(@"loading %@ to %@", self.imageURL, path);

        return nil;

    } else {

        return [UIImage imageWithContentsOfFile:path];
    }
}

- (NSString *)timeIntervalString
{
    if ([begin timeIntervalSinceNow] > 18*kOneHour) {
        return [NSString stringWithFormat:@"%@ %@–%@", begin.weekdayName, begin.hourAndMinuteString, end.hourAndMinuteString];
    } else {
        // no need to display weekday name as a part of a current-day gig:
        return [NSString stringWithFormat:@"%@–%@", begin.hourAndMinuteString, end.hourAndMinuteString];
    }
}

- (NSString *)stageAndTimeIntervalString
{
    return [NSString stringWithFormat:@"%@ %@–%@ %@", begin.weekdayName, begin.hourAndMinuteString, end.hourAndMinuteString, venue];
}

- (NSTimeInterval)duration
{
	return [self.end timeIntervalSinceDate:self.begin];
}

- (NSComparisonResult)compare:(Gig *)otherGig
{
    return [self.begin compare:otherGig.begin];
}

@end
