//
//  TimelineView.m
//  FestApp
//

#import "TimelineView.h"
#import "FestApp-Swift.h"
#import "NSDate+Additions.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - GigButton

@interface GigButton : UIButton
@property (nonatomic, readonly) Gig *gig;
- (id)initWithFrame:(CGRect)frame gig:(Gig *)gig;
@end

@implementation GigButton

- (id)initWithFrame:(CGRect)frame gig:(Gig *)gig
{
    self = [super initWithFrame:frame];
    if (self) {
        _gig = gig;

        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [self setTitle:gig.gigName.uppercaseString forState:UIControlStateNormal];

        self.backgroundColor = [UIColor grayColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        [self setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"star-selected-yellow.png"] forState:UIControlStateSelected];

        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.numberOfLines = 3;

        self.titleLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:15];
    }
    return self;
}
@end

@interface FavButton : UIButton
@property (nonatomic, readonly) Gig *gig;
- (id)initWithFrame:(CGRect)frame gig:(Gig *)gig;
@end

@implementation FavButton
- (id)initWithFrame:(CGRect)frame gig:(Gig *)gig
{
    self = [super initWithFrame:frame];
    if (self) {
        _gig = gig;
    }
    return self;
}
@end

#pragma mark - TimeLineView

@interface TimelineView ()
@property (nonatomic, strong) NSArray *stages;

@property (nonatomic, strong) NSDate *begin;
@property (nonatomic, strong) NSDate *end;

@property (nonatomic, strong) NSDate *dayBegin;
@property (nonatomic, strong) NSDate *dayEnd;

@property (nonatomic, strong) UIView *innerView;
@end

#define kHourWidth 200
#define kRowHeight 110
#define kTopPadding 20
#define kLeftPadding 50
#define kRightPadding 20
#define kRowPadding 5

CGFloat timeWidthFrom(NSDate *from, NSDate *to);

CGFloat timeWidthFrom(NSDate *from, NSDate *to)
{
    NSTimeInterval interval = [to timeIntervalSinceReferenceDate] - [from timeIntervalSinceReferenceDate];
    return (CGFloat) interval / 3600 * kHourWidth;
}

@implementation TimelineView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    [self performSelectorInBackground:@selector(preloadGroovyGuitarSounds) withObject:nil];

    self.innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self addSubview:self.innerView];
}

- (CGRect)gigRect:(Gig *)gig
{
    if ([gig.day isEqualToString:self.currentDay]) {
        CGFloat x = - kLeftPadding + timeWidthFrom(self.dayBegin, gig.begin);
        CGFloat w = timeWidthFrom(gig.begin, gig.end);
        return CGRectMake(x, 0, w, 1);
    } else {
        return CGRectMake(0, 0, 1, 1);
    }
}

#pragma mark - DataSetters
- (void)setGigs:(NSArray *)gigs
{
    _gigs = gigs;

#if 0
    NSUInteger count = gigs.count;

    // Venues
    NSMutableArray *stages = [NSMutableArray arrayWithCapacity:6];
    for (NSUInteger idx = 0; idx < count; idx++) {
        Gig *gig = gigs[idx];
        if (![stages containsObject:gig.stage]) {
            [stages addObject:gig.stage];
        }
    }
#endif

    // HARDCODE order
    self.stages = @[@"Computing", @"Type Theory", @"Logic"];

    [self recreate];
    [self invalidateIntrinsicContentSize];
}

- (void)setFavouritedGigs:(NSArray *)favouritedGigs
{
    _favouritedGigs = favouritedGigs;

    for (UIView *view in self.innerView.subviews) {
        if ([view isKindOfClass:[GigButton class]]) {
            GigButton *button = (GigButton *)view;

            BOOL favourited = [self.favouritedGigs containsObject:button.gig.gigId];

            button.selected = favourited;
            button.alpha = favourited ? 1.0f : 0.8f;
        }
    }
}

- (void)setCurrentDay:(NSString *)currentDay
{
    _currentDay = currentDay;

    [self recreateDay];
    [self invalidateIntrinsicContentSize];
}

#pragma mark - Internals

- (void)recreateDay
{
    NSDate *begin = [NSDate distantFuture];
    NSDate *end = [NSDate distantPast];

    for (Gig *gig in self.gigs) {
        if (![gig.day isEqualToString:self.currentDay]) {
            continue;
        }

        if ([gig.begin compare:begin] == NSOrderedAscending ) {
            begin = gig.begin;
        }

        if ([gig.end compare:end] == NSOrderedDescending) {
            end = gig.end;
        }
    }

    self.dayBegin = begin;
    self.dayEnd = end;


    CGFloat x = kLeftPadding - timeWidthFrom(self.begin, self.dayBegin);
    CGFloat y = 0;
    CGFloat w = timeWidthFrom(self.begin, self.end) + kRightPadding;
    CGFloat h = kTopPadding + kRowHeight * 5;

    [UIView animateWithDuration:0.5 animations:^{
        self.innerView.frame = CGRectMake(x, y, w, h);
    }];
}

- (void)recreate
{
    for (UIView *view in self.innerView.subviews) {
        [view removeFromSuperview];
    }

    NSUInteger count = self.gigs.count;
    if (count == 0) {
        return;
    }

    // timespan
    NSDate *begin = [NSDate distantFuture];
    NSDate *end = [NSDate distantPast];

    for (Gig *gig in self.gigs) {
        if ([gig.begin compare:begin] == NSOrderedAscending ) {
            begin = gig.begin;
        }

        if ([gig.end compare:end] == NSOrderedDescending) {
            end = gig.end;
        }
    }

    self.begin = begin;
    self.end = end;

    // Frets
    NSUInteger interval = (NSUInteger) [self.begin timeIntervalSinceReferenceDate] % 3600;
    if (interval < 60) {
        interval = -interval;
    } else {
        interval = 3600 - interval;
    }

    NSDate *fretDate = [NSDate dateWithTimeInterval:interval sinceDate:self.begin];
    UIImage *fretImage = [UIImage imageNamed:@"schedule-hoursep.png"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];

    while ([fretDate compare:self.end] == NSOrderedAscending) {
        // fret
        CGRect frame = CGRectMake(timeWidthFrom(self.begin, fretDate) - 2, 0, 4, 350);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = fretImage;

        [self.innerView addSubview:imageView];

        // time label
        CGRect timeFrame = CGRectMake(timeWidthFrom(self.begin, fretDate) - 50, 0, 100, 20);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeFrame];

        timeLabel.textColor = [UIColor blackColor];
        timeLabel.text = [dateFormatter stringFromDate:fretDate];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:17];

        [self.innerView addSubview:timeLabel];

        // next
        fretDate = [NSDate dateWithTimeInterval:3600 sinceDate:fretDate];
    }

    NSUInteger stageCount = self.stages.count;

    // buttons
    for (Gig *gig in self.gigs) {
        NSUInteger stageIdx = 0;
        for (; stageIdx < stageCount; stageIdx++) {
            if ([gig.stage isEqualToString:self.stages[stageIdx]]) {
                break;
            }
        }

        BOOL favourited = [self.favouritedGigs containsObject:gig.gigId];

        CGFloat x = timeWidthFrom(self.begin, gig.begin);
        CGFloat y = kTopPadding + kRowPadding + kRowHeight * stageIdx;
        CGFloat w = timeWidthFrom(gig.begin, gig.end);
        CGFloat h = kRowHeight - kRowPadding * 2;
        CGRect frame = CGRectMake(x, y, w, h);

        GigButton *button = [[GigButton alloc] initWithFrame:frame gig:gig];

        button.selected = favourited;
        button.alpha = favourited ? 1.0f : 0.8f;

        [button addTarget:self action:@selector(gigButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        CGRect favFrame = CGRectMake(x, y, 40, h);
        FavButton *favButton = [[FavButton alloc] initWithFrame:favFrame gig:gig];

        [favButton addTarget:self action:@selector(favButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self.innerView addSubview:button];
        [self.innerView addSubview:favButton];
    }

    [self recreateDay];
}

#pragma mark - Actions

- (void)gigButtonPressed:(GigButton *)sender
{
    [self.delegate timeLineView:self gigSelected:sender.gig];
}

- (void)favButtonPressed:(FavButton *)sender
{
    Gig *gig = sender.gig;
    BOOL favourited = [self.favouritedGigs containsObject:gig.gigId];
    [self.delegate timeLineView:self gigFavourited:gig favourite:!favourited];
}

#pragma mark - AutoLayout
- (CGSize)intrinsicContentSize
{
    return CGSizeMake(timeWidthFrom(self.dayBegin, self.dayEnd) + kLeftPadding, 100);
}

#pragma mark - Audio

- (void)preloadGroovyGuitarSounds
{
    @autoreleasepool {
        for (int i = 0; i < 2; i++) {
            [self playGroovyGuitarSound:i volume:0];
        }
    }
}

- (void)playGroovyGuitarSound:(int)soundNumber volume:(float)volume
{
    return;
}

@end
