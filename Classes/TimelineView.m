//
//  TimelineView.m
//  FestApp
//

#import "TimelineView.h"
#import "Artist.h"
#import "NSDate+Additions.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - ArtistButton

@interface ArtistButton : UIButton
@property (nonatomic, readonly) Artist *artist;
- (id)initWithFrame:(CGRect)frame artist:(Artist *)artist;
@end

@implementation ArtistButton

- (id)initWithFrame:(CGRect)frame artist:(Artist *)artist
{
    self = [super initWithFrame:frame];
    if (self) {
        _artist = artist;

        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [self setTitle:artist.artistName forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];

        self.backgroundColor = RR_COLOR_DARKGREEN;
        [self setTitleColor:RR_COLOR_YELLOW forState:UIControlStateSelected];
        [self setTitleColor:RR_COLOR_LIGHTGREEN forState:UIControlStateNormal];

        [self setImage:[UIImage imageNamed:@"schedule_favourite.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"schedule_favourite_selected.png"] forState:UIControlStateSelected];

        self.titleLabel.adjustsFontSizeToFitWidth = TRUE;
        self.titleLabel.minimumScaleFactor = 8/14.0f;
    }
    return self;
}
@end

@interface FavButton : UIButton
@property (nonatomic, readonly) Artist *artist;
- (id)initWithFrame:(CGRect)frame artist:(Artist *)artist;
@end

@implementation FavButton
- (id)initWithFrame:(CGRect)frame artist:(Artist *)artist
{
    self = [super initWithFrame:frame];
    if (self) {
        _artist = artist;
    }
    return self;
}
@end

#pragma mark - TimeLineView

@interface TimelineView () <AVAudioPlayerDelegate>
@property (strong) AVAudioPlayer *currentPlayer;

@property (nonatomic, strong) NSArray *venues;

@property (nonatomic, strong) NSDate *begin;
@property (nonatomic, strong) NSDate *end;

@property (nonatomic, strong) NSDate *dayBegin;
@property (nonatomic, strong) NSDate *dayEnd;

@property (nonatomic, strong) UIView *innerView;
@end

#define kHourWidth 200
#define kRowHeight 49
#define kTopPadding 45
#define kLeftPadding 80
#define kRightPadding 40
#define kRowPadding 5

CGFloat timeWidthFrom(NSDate *from, NSDate *to);

CGFloat timeWidthFrom(NSDate *from, NSDate *to)
{
    NSTimeInterval interval = [to timeIntervalSinceReferenceDate] - [from timeIntervalSinceReferenceDate];
    return (CGFloat) interval / 3600 * kHourWidth;
}

@implementation TimelineView

@synthesize currentPlayer;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    [self performSelectorInBackground:@selector(preloadGroovyGuitarSounds) withObject:nil];

    self.innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self addSubview:self.innerView];
}

- (CGRect)artistRect:(Artist *)artist
{
    if ([artist.day isEqualToString:self.currentDay]) {
        CGFloat x = - kLeftPadding + timeWidthFrom(self.dayBegin, artist.begin);
        CGFloat w = timeWidthFrom(artist.begin, artist.end);
        return CGRectMake(x, 0, w, 1);
    } else {
        return CGRectMake(0, 0, 1, 1);
    }
}

#pragma mark - DataSetters
- (void)setArtists:(NSArray *)artists
{
    _artists = artists;
    NSUInteger count = artists.count;

    // Venues
    NSMutableArray *venues = [NSMutableArray arrayWithCapacity:6];
    for (NSUInteger idx = 0; idx < count; idx++) {
        Artist *artist = artists[idx];
        if (![venues containsObject:artist.venue]) {
            [venues addObject:artist.venue];
        }
    }

    self.venues = venues;

    [self recreate];
    [self invalidateIntrinsicContentSize];
}

- (void)setFavouritedArtists:(NSArray *)favouritedArtists
{
    _favouritedArtists = favouritedArtists;

    for (UIView *view in self.innerView.subviews) {
        if ([view isKindOfClass:[ArtistButton class]]) {
            ArtistButton *button = (ArtistButton *)view;

            BOOL favourited = [self.favouritedArtists containsObject:button.artist.artistId];

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

    for (Artist *artist in self.artists) {
        if (![artist.day isEqualToString:self.currentDay]) {
            continue;
        }

        if ([artist.begin compare:begin] == NSOrderedAscending ) {
            begin = artist.begin;
        }

        if ([artist.end compare:end] == NSOrderedDescending) {
            end = artist.end;
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

    NSUInteger count = self.artists.count;
    if (count == 0) {
        return;
    }

    // timespan
    NSDate *begin = [NSDate distantFuture];
    NSDate *end = [NSDate distantPast];

    for (Artist *artist in self.artists) {
        if ([artist.begin compare:begin] == NSOrderedAscending ) {
            begin = artist.begin;
        }

        if ([artist.end compare:end] == NSOrderedDescending) {
            end = artist.end;
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
    UIImage *fretImage = [UIImage imageNamed:@"fret.png"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];

    while ([fretDate compare:self.end] == NSOrderedAscending) {
        // fret
        CGRect frame = CGRectMake(kLeftPadding + timeWidthFrom(self.begin, fretDate) - 10, 30, 17, 276);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = fretImage;

        [self.innerView addSubview:imageView];

        // time label
        CGRect timeFrame = CGRectMake(kLeftPadding + timeWidthFrom(self.begin, fretDate) - 28, 0, 60, 30);
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeFrame];

        timeLabel.textColor = RR_COLOR_DARKGREEN;
        timeLabel.text = [dateFormatter stringFromDate:fretDate];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];

        [self.innerView addSubview:timeLabel];

        // next
        fretDate = [NSDate dateWithTimeInterval:3600 sinceDate:fretDate];
    }

    NSUInteger venueCount = self.venues.count;

    // buttons
    for (Artist *artist in self.artists) {
        NSUInteger venueIdx = 0;
        for (; venueIdx < venueCount; venueIdx++) {
            if ([artist.venue isEqualToString:self.venues[venueIdx]]) {
                break;
            }
        }

        BOOL favourited = [self.favouritedArtists containsObject:artist.artistId];

        CGFloat x = timeWidthFrom(self.begin, artist.begin);
        CGFloat y = kTopPadding + kRowPadding + kRowHeight * venueIdx;
        CGFloat w = MAX(timeWidthFrom(artist.begin, artist.end), kHourWidth);
        CGFloat h = kRowHeight - kRowPadding * 2;
        CGRect frame = CGRectMake(x, y, w, h);

        ArtistButton *button = [[ArtistButton alloc] initWithFrame:frame artist:artist];

        button.selected = favourited;
        button.alpha = favourited ? 1.0f : 0.8f;

        [button setBackgroundImage:[UIImage imageNamed:@"favourited-artist.png"] forState:UIControlStateSelected];

        [button addTarget:self action:@selector(artistButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        CGRect favFrame = CGRectMake(x, y, 40, h);
        FavButton *favButton = [[FavButton alloc] initWithFrame:favFrame artist:artist];

        [favButton addTarget:self action:@selector(favButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self.innerView addSubview:button];
        [self.innerView addSubview:favButton];
    }

    [self recreateDay];
}

#pragma mark - Actions

- (void)artistButtonPressed:(ArtistButton *)sender
{
    [self.delegate timeLineView:self artistSelected:sender.artist];
}

- (void)favButtonPressed:(FavButton *)sender
{
    Artist *artist = sender.artist;
    BOOL favourited = [self.favouritedArtists containsObject:artist.artistId];
    [self.delegate timeLineView:self artistFavourited:artist favourite:!favourited];
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
    NSString *soundName = (soundNumber%2) ? @"Riff1" : @"Riff2";
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"aif"];

    self.currentPlayer = [self playerForSoundPath:soundPath];
    currentPlayer.volume = volume;
    [currentPlayer play];

    if (volume > 0) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

#pragma mark - AVAudioPlayerDelegate
- (AVAudioPlayer *)playerForSoundPath:(NSString *)path
{
    NSURL *soundURL = [NSURL fileURLWithPath:path];
    NSError *error;

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSError *activationError = nil;
    [session setActive:YES error:&activationError];

    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    player.delegate = self;
    return player;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.currentPlayer = nil;
}

@end
