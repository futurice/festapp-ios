//
//  TimelineView.h
//  FestApp
//

#import <UIKit/UIKit.h>
#import "Artist.h"

@class TimelineView;

@protocol TimelineViewDelegate
- (void)timeLineView:(TimelineView *)timeLineView artistSelected:(Artist *)artist;
- (void)timeLineView:(TimelineView *)timeLineView artistFavourited:(Artist *)artist favourite:(BOOL)favourite;
@end


@interface TimelineView : UIView
@property (nonatomic, strong) NSArray *artists;
@property (nonatomic, strong) NSString *currentDay;
@property (nonatomic, strong) NSArray *favouritedArtists;

@property (nonatomic, weak) id<TimelineViewDelegate> delegate;
@end
