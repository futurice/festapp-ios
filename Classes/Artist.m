//
//  Gig.m
//  FestApp
//

#import "Artist.h"
#import "NSDate+Additions.h"
#import <CoreLocation/CoreLocation.h>

#import "AFNetworking.h"
#import "FestHTTPSessionManager.h"

@interface Artist ()

@end

@implementation Artist

@dynamic timeIntervalString;
@dynamic stageAndTimeIntervalString;
@dynamic duration;

NSInteger alphabeticalGigSort(id gig1, id gig2, void *context)
{
    NSString *artist1 = [(Artist *) gig1 artistName];
    NSString *artist2 = [(Artist *) gig2 artistName];
    return [artist1 compare:artist2 options:NSCaseInsensitiveSearch];
}

NSInteger chronologicalGigSort(id gig1, id gig2, void *context)
{
    NSDate *begin1 = [(Artist *) gig1 begin];
    NSDate *begin2 = [(Artist *) gig2 begin];
    return [begin1 compare:begin2];
}

+ (NSArray *)gigsFromArrayOfDicts:(NSArray *)dicts
{
	NSMutableArray *gigs = [NSMutableArray arrayWithCapacity:[dicts count]];

    NSUInteger gigCount = [dicts count];
    NSLog(@"parsing %d gigs", gigCount);

	for (NSUInteger i = 0; i < gigCount; i++) {

        NSDictionary *dict = dicts[i];

		Artist *gig            = [[Artist alloc] init];
		gig.artistId        = dict[@"id"];
		gig.artistName      = dict[@"nimi"];
		gig.venue           = dict[@"lava"];
        gig.description     = dict[@"kohokohtia"];
        gig.day             = dict[@"paiva"];
        gig.quote           = dict[@"quote"];
        gig.founded         = dict[@"perustettu"];
        gig.members         = [dict[@"jasenet"] stringByReplacingOccurrencesOfString:@"|" withString:@", "];

        NSString *spotifyUrlStr = dict[@"spotify"];
        if([spotifyUrlStr length] != 0) {
            gig.spotifyUrl = [NSURL URLWithString:spotifyUrlStr];
        }
        
        NSString *youtubeUrlStr = dict[@"youtube"];
        if([youtubeUrlStr length] != 0) {
            gig.youtubeUrl = [NSURL URLWithString:youtubeUrlStr];
        }

        NSString *imagePath = dict[@"kuva"];
        if (imagePath) {
            gig.imagePath = imagePath;
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

        NSTimeInterval begin = [dict[@"aika"] doubleValue];
        NSTimeInterval end   = [dict[@"aika_stop"] doubleValue];

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

            for (Artist *existingGig in gigs) {

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

- (NSString *)timeIntervalString
{
    if ([self.begin timeIntervalSinceNow] > 18*kOneHour) {
        return [NSString stringWithFormat:@"%@ %@–%@", self.begin.weekdayName, self.begin.hourAndMinuteString, self.end.hourAndMinuteString];
    } else {
        // no need to display weekday name as a part of a current-day gig:
        return [NSString stringWithFormat:@"%@–%@", self.begin.hourAndMinuteString, self.end.hourAndMinuteString];
    }
}

- (NSString *)stageAndTimeIntervalString
{
    return [NSString stringWithFormat:@"%@ %@–%@ %@", self.begin.weekdayName, self.begin.hourAndMinuteString, self.end.hourAndMinuteString, self.venue];
}

- (NSTimeInterval)duration
{
	return [self.end timeIntervalSinceDate:self.begin];
}

- (NSComparisonResult)compare:(Artist *)otherGig
{
    return [self.begin compare:otherGig.begin];
}

- (NSString *)debugDescription
{
    return self.artistName;
}

@end
