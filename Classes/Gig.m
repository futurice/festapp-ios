//
//  Gig.m
//  FestApp
//

#import "Gig.h"
#import "NSDate+Additions.h"
#import <CoreLocation/CoreLocation.h>

#import "AFNetworking.h"
#import "FestHTTPSessionManager.h"

@interface Gig ()

@end

@implementation Gig

@dynamic timeIntervalString;
@dynamic stageAndTimeIntervalString;
@dynamic duration;

- (instancetype)initFromJSON:(NSDictionary *)json
{
    self = [super init];
    if (self) {
        // http://stackoverflow.com/questions/4999396/how-to-parse-a-date-string-into-an-nsdate-object-in-ios
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];

        _begin    = [dateFormatter dateFromString:json[@"start-time"]];
        _end      = [dateFormatter dateFromString:json[@"end-time"]];
        _stage    = json[@"stage"];
        _day      = json[@"day"];

        NSDictionary *artist = json[@"artist"];

		_gigId    = artist[@"id"];
		_gigName  = artist[@"name"];
        _info     = artist[@"info"];

        NSString *wikipediaUrlString = artist[@"wikipedia"];
        if([wikipediaUrlString length] != 0) {
            _wikipediaUrl = [NSURL URLWithString:wikipediaUrlString];
        }

        NSString *imagePath = [NSString stringWithFormat:@"%@.jpg", artist[@"id"]];
        if (imagePath) {
            _imagePath = imagePath;
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
    NSString *end = [self.end.hourAndMinuteString isEqualToString:@"23:59"] ? @"00:00" : self.end.hourAndMinuteString;
    return [NSString stringWithFormat:@"%@ %@–%@ %@", self.begin.weekdayName, self.begin.hourAndMinuteString, end, self.stage];
}

- (NSTimeInterval)duration
{
	return [self.end timeIntervalSinceDate:self.begin];
}

- (NSString *)debugDescription
{
    return self.gigName;
}

@end
