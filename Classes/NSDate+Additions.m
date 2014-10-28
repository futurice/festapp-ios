//
//  NSDate+Additions.m
//  FestApp
//

#import "NSDate+Additions.h"


@implementation NSDate (NSDate_Additions)

+ (NSCalendar *)currentCalendar
{
    static NSCalendar *currentCalendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentCalendar = [NSCalendar currentCalendar];
    });
    return currentCalendar;
}

- (BOOL)before:(NSDate *)other
{
	return ([self compare:other] < 0);
}

- (BOOL)after:(NSDate *)other
{
	return ([self compare:other] > 0);
}

- (float)hourValueWithDayDelimiterHour:(NSInteger)dayDelimiterHour
{
	NSUInteger flags = (kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond);
	NSDateComponents *components = [[NSDate currentCalendar] components:flags fromDate:self];
	NSInteger hour = [components hour];
	NSInteger minute = [components minute];
	NSInteger second = [components second];
	if (hour < dayDelimiterHour) {
		hour += 24;
	}
	float hourValue = hour + (minute/60.0f) + (second/((float) 60 * 60));
	return hourValue;
}

- (NSInteger)hour
{
	NSDateComponents *components = [[NSDate currentCalendar] components:NSHourCalendarUnit fromDate:self];
	return [components hour];
}

- (NSInteger)minute
{
	NSDateComponents *components = [[NSDate currentCalendar] components:NSHourCalendarUnit fromDate:self];
	return [components minute];
}

- (NSString *)hourAndMinuteString
{
	NSDateFormatter *formatter = [NSDate dateFormatterWithFormat:@"HH:mm"];
	return [formatter stringFromDate:self];
}

- (NSString *)weekdayName
{
    NSDateFormatter *dateFormatter = [NSDate dateFormatterWithFormat:@"EEEE"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSString *dayName = [dateFormatter stringFromDate:self];
    return NSLocalizedString(dayName, nil);
}

- (NSString *)posixWeekdayName
{
    NSDateFormatter *dateFormatter = [NSDate dateFormatterWithFormat:@"EEEE"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSString *dayName = [dateFormatter stringFromDate:self];
    return dayName;
}

- (NSDate *)sameDateWithMidnightTimestamp
{
    NSDateFormatter *dateFormatter = [NSDate dateFormatterWithFormat:@"dd-MM-yyyy"];
    NSDate *date = [self dateByAddingTimeInterval:(([self hour] < kDayDelimiterHour) ? -24*kOneHour : 0)];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return [dateFormatter dateFromString:dateString];
}

+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format
{
    NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *formatter = threadDict[format];
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = format;
        threadDict[format] = formatter;
    }
    return formatter;
}

@end
