#import "NSDate+Additions.h"
#import "NSString+Additions.h"
#import "UIView+XYWidthHeight.h"

#define kResourceBaseURL           @"http://www.ruisrock.fi/"
#define RR_NEWS_JSON_URL           @"/api/uutiset"
#define RR_ARTISTS_JSON_URL        @"/api/artistit"

#define kResourceImageURLFormat    @"http://ruisrock.fi/admin/%@"

#define kResourceTypeSuffix        @"json"

#define kResourceNameBands         @"artists"
#define kResourceNameNews          @"news"
#define kResourceNameFAQ           @"faq"
#define kResourceNameFoodAndDrinks @"program"

#define kResourceNameGeneral       @"general"
#define kResourceNameServices      @"services"
#define kResourceNameArrival       @"arrival"
#define kResourceNameStages        @"stages"

typedef enum FestResourceEnum {
    FestResourceArtists,
    FestResourceNews,
    FestResourceFaq,
    FestResoucreProgram,
    FestResourceGeneral,
    FestResourceServices,
    FestResourceStages
} FestResource;

#define kFestResourceCount         ((NSUInteger) 7)

#define kResourceLastUpdatedPrefix @"lastModified"

// Resource poll interval in seconds
#ifdef NDEBUG
#define kResourcePollInterval      10*60
#else
#define kResourcePollInterval      60
#endif

#define kResource                  @[kResourceNameBands, kResourceNameNews]
#define kDataItemsInRefreshOrder   @[kResourceNameFAQ, kResourceNameFoodAndDrinks]

#define kRefreshIntervalInHours    (6)

#define kAlertIntervalInMinutes    15

#define kMapScaleFactor            0.5f

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

#define kNotificationForLoadedArtistImage        @"loaded artist image"
#define kNotificationForFailedLoadingArtistImage @"failed loading artist image"

// Colors

#define kColorRed         [UIColor colorWithRed:0/255.0f green: 0/255.0f blue: 0/255.0f alpha:1] // black is a new red
#define kColorYellowLight [UIColor colorWithRed:221/255.0f green:221/255.0f blue:221/255.0f alpha:1] // gray is a new yellow

// Delegate
#define APPDELEGATE ((FestAppDelegate *)[[UIApplication sharedApplication] delegate])

// To detect iOS 7

#define iOS7 ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)

@interface NSObject (Cast)
+ (instancetype)cast:(id)object;
@end

@implementation NSObject (Cast)
+ (instancetype)cast:(id)object
{
    return [object isKindOfClass:self] ? object : nil;
}
@end
