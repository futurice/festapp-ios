//
//  TimelineViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>
#import "TimelineView.h"
#import "DayChooser.h"

#define kVenueSlateWidth 67
#define kVenueSlateHeight 26

@class GigViewController;
@class DayChooser;

@interface TimelineViewController : UIViewController <TimelineViewDataSource, TimelineViewDelegate, DayChooserDelegate, UIScrollViewDelegate> {

    NSArray *gigs;

    NSUInteger selectedDayIndex;
    int slideDirection;
    BOOL firstViewingSinceStartup;
    CGPoint pointOfBeginTouch;
}

@property (strong, nonatomic) NSDictionary *gigsByDayThenByVenue;
@property (strong, nonatomic) NSArray *days;
@property (strong, nonatomic) NSArray *venues;

@property (strong, nonatomic) NSDate *selectedDay;
@property (strong, nonatomic) NSDate *earliestHour;
@property (strong, nonatomic) NSDate *latestHour;
@property (strong, nonatomic) NSString *selectedVenue;

@property (strong, nonatomic) IBOutlet TimelineView *timelineView;
@property (strong, nonatomic) IBOutlet UIScrollView *timelineScrollView;
@property (strong, nonatomic) IBOutlet GigViewController *gigViewController;
@property (strong, nonatomic) DayChooser *dayChooser;
@property (strong, nonatomic) NSArray *venueLabels;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

- (IBAction)daySelected;
- (IBAction)venueSelected:(UIButton *)button;
- (void)setSelectedVenue:(NSString *)venue;
- (void)selectCurrentDayIfViable;

- (Gig *)nextGigForDate:(NSDate *)date onVenue:(NSString *)venue;
- (void)scrollToGig:(Gig *)gig;

@end
