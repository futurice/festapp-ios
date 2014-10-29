//
//  TimelineView.h
//  FestApp
//

#import <UIKit/UIKit.h>
#import "FestApp-Swift.h"

@class TimelineView;

@protocol TimelineViewDelegate
- (void)timeLineView:(TimelineView *)timeLineView gigSelected:(Gig *)gig;
- (void)timeLineView:(TimelineView *)timeLineView gigFavourited:(Gig *)gig favourite:(BOOL)favourite;
@end


@interface TimelineView : UIView
@property (nonatomic, strong) NSArray *gigs;
@property (nonatomic, strong) NSString *currentDay;
@property (nonatomic, strong) NSArray *favouritedGigs;

@property (nonatomic, weak) id<TimelineViewDelegate> delegate;

- (CGRect)gigRect:(Gig *)gig;
@end
