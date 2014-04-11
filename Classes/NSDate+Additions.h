//
//  NSDate+Additions.h
//  FestApp
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDate_Additions)

- (BOOL)before:(NSDate *)other;
- (BOOL)after:(NSDate *)other;
- (int)hour;
- (int)minute;
- (NSDate *)sameDateWithMidnightTimestamp;
- (float)hourValueWithDayDelimiterHour:(int)dayDelimiterHour;
- (NSString *)hourAndMinuteString;
- (NSString *)weekdayName;

+ (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format;

@end
