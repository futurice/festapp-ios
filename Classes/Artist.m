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

- (instancetype)initFromJSON:(NSDictionary *)json
{
    self = [super init];
    if (self) {
		_artistId        = json[@"id"];
		_artistName      = json[@"nimi"];
		_venue           = json[@"lava"];
        _description     = json[@"kohokohtia"];
        _day             = json[@"paiva"];
        _quote           = json[@"quote"];
        _founded         = json[@"perustettu"];
        _members         = [json[@"jasenet"] stringByReplacingOccurrencesOfString:@"|" withString:@", "];

        NSString *spotifyUrlStr = json[@"spotify"];
        if([spotifyUrlStr length] != 0) {
            _spotifyUrl = [NSURL URLWithString:spotifyUrlStr];
        }
        
        NSString *youtubeUrlStr = json[@"youtube"];
        if([youtubeUrlStr length] != 0) {
            _youtubeUrl = [NSURL URLWithString:youtubeUrlStr];
        }

        NSString *imagePath = json[@"kuva"];
        if (imagePath) {
            _imagePath = imagePath;
        }

        NSScanner *scanner = [NSScanner scannerWithString:_artistName];
        NSString *text = nil;

        while ([scanner isAtEnd] == NO) {
            [scanner scanUpToString:@"(" intoString:NULL];
            [scanner scanUpToString:@")" intoString:&text];

            if (text != nil) {
                _country = [text substringFromIndex:1];  // omit the (
                _artistName = [_artistName stringByReplacingOccurrencesOfString:_country withString:_country.uppercaseString];
            }
        }

        NSTimeInterval begin = [json[@"aika"] doubleValue];
        NSTimeInterval end   = [json[@"aika_stop"] doubleValue];

        if (begin > 0 && end > 0 && _venue != nil && ![_venue isEqual:[NSNull null]]) {

            _begin = [NSDate dateWithTimeIntervalSince1970:begin];
            _end = [NSDate dateWithTimeIntervalSince1970:end];

            // Taking into account the magical year 2103 summer gig:
            if ([_end timeIntervalSinceDate:_begin] > 24 * kOneHour) {
                _end = [_begin dateByAddingTimeInterval:(2 * kOneHour)];
            }

           // NSLog(@"%@ %@ - %@", gig.artistName, gig.begin, gig.end);

            NSTimeInterval timeInterval = floor(-kOneHour*[_begin hourValueWithDayDelimiterHour:6]);
            if (((int)timeInterval)%10 != 0) {
                timeInterval -= ((int)timeInterval)%10;
            }

            _date = [_begin dateByAddingTimeInterval:timeInterval];
            // NSLog(@"%f %@", timeInterval, gig.artistName);
        }
    }
    return self;
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
