#import "NSDate+Additions.h"
#import "NSString+Additions.h"
#import "UIView+XYWidthHeight.h"

#define kResourceBaseURL           @"http://127.0.0.1:3003"
#define FEST_FESTIVAL_JSON_URL     @"/api/festival"
#define FEST_NEWS_JSON_URL         @"/api/news"
#define FEST_GIGS_JSON_URL         @"/api/gigs"
#define FEST_INFO_JSON_URL         @"/api/info"

#define kResourceLastUpdatedPrefix @"lastModified"

// Resource poll interval in seconds
#ifdef NDEBUG
#define kResourcePollInterval      10*60
#else
#define kResourcePollInterval      60
#endif

#define kRefreshIntervalInHours    (6)

#define kAlertIntervalInMinutes    15

#define kOneMinute                (60)
#define kOneHour                  (60*60)
#define kDayDelimiterHour          6

#define kHourWidth                 200
#define kVenueRowHeight            48

#define kLatestSeenNewsPubDateKey             @"latestSeenNewsPubDate"
#define kLastRefreshTimestampKey              @"lastRefreshTimestamp"
#define kFavoritingInstructionAlreadyShownKey @"favoritingInstructionAlreadyShown"
#define kFavoritingInstructionShownCounterKey @"favoritingInstructionShownCounter"
#define kUniqueUserIDKey                      @"unique user id"
#define kDistanceFromFestKey                  @"distance from fest"

// Notifications
#define kNotificationForLoadedGigImage        @"loaded gig image"
#define kNotificationForFailedLoadingGigImage @"failed loading gig image"

// Colors
#define RGB_COLOR(r,g,b)  [UIColor colorWithRed:r/255.0f green: g/255.0f blue: b/255.0f alpha:1]

#define FEST_COLOR_GOLD      RGB_COLOR(204, 153, 0)

// Delegate
#define APPDELEGATE ((FestAppDelegate *)[[UIApplication sharedApplication] delegate])

// TODO: move me
@interface NSObject (Cast)
+ (instancetype)cast:(id)object;
@end

@implementation NSObject (Cast)
+ (instancetype)cast:(id)object
{
    return [object isKindOfClass:self] ? object : nil;
}
@end
