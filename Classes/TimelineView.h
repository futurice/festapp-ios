//
//  TimelineView.h
//  FestApp
//

#import <UIKit/UIKit.h>

#define kOneHour (60*60)
#define kStarAreaWidth 32
#define kMinWidthForArtistName 60

@class Artist;


@protocol TimelineViewDataSource

- (NSUInteger)numberOfVenues;
- (NSArray *)gigsForVenueAtIndex:(NSUInteger)index;
- (NSDate *)earliestHour;
- (NSDate *)latestHour;

@end


@protocol TimelineViewDelegate

- (NSInteger)heightForVenueRow;
- (NSInteger)widthForVenueLabel;
- (NSInteger)heightForTimeScale;
- (NSInteger)widthForOneHour;
- (void)gigSelected:(Artist *)gig;
- (void)gigFavoriteStatusToggled:(Artist *)gig;

@end


@interface TimelineView : UIView {

    CGPoint pointOfBeginTouch;
}

@property (nonatomic, weak) id<TimelineViewDataSource> dataSource;
@property (nonatomic, weak) id<TimelineViewDelegate> delegate;

- (void)reloadData;
- (NSInteger)xFromDate:(NSDate *)date;

@end
