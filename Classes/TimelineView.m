//
//  TimelineView.m
//  FestApp
//

#import "TimelineView.h"
#import "Artist.h"
#import "NSDate+Additions.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

@interface TimelineView () <AVAudioPlayerDelegate>

@property (strong) AVAudioPlayer *currentPlayer;

- (NSInteger)widthFromTimeInterval:(NSTimeInterval)timeInterval;
- (void)playGroovyGuitarSound:(int)soundNumber volume:(float)volume;
- (AVAudioPlayer *)playerForSoundPath:(NSString *)path;

@end


@implementation TimelineView

@synthesize dataSource;
@synthesize delegate;

@synthesize currentPlayer;

- (void)awakeFromNib
{
    [self performSelectorInBackground:@selector(preloadGroovyGuitarSounds) withObject:nil];
}

- (void)reloadData
{
    // NSLog(@"%@", self);
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef c = UIGraphicsGetCurrentContext();

    CGContextClearRect(c, rect);

    UIFont *timeLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
	UIFont *artistLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:13];

	CGFloat venueHeight = [delegate heightForVenueRow];
	CGFloat timeScaleHeight = [delegate heightForTimeScale];

	NSDate *earliestHour = [dataSource earliestHour];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:00"];

	int hourCount = (int) [[dataSource latestHour] timeIntervalSinceDate:earliestHour]/kOneHour;

	CGContextSetStrokeColorWithColor(c, [[UIColor lightGrayColor] CGColor]);
	CGContextSetFillColorWithColor(c, kColorRed.CGColor);
	CGContextSetLineWidth(c, 1);

    UIImage *fretImage = [UIImage imageNamed:@"fret.png"];
    CGSize fretSize = CGSizeMake(17, 276); // 34, 552 - 17, 276

	for (int i = 1; i <= hourCount; i++) {

		NSDate *hourDate = [earliestHour dateByAddingTimeInterval:i*kOneHour];
		NSString *hourString = [dateFormatter stringFromDate:hourDate];
		CGSize hourStringSize = [hourString sizeWithAttributes:@{NSFontAttributeName:timeLabelFont}];
		NSInteger hourX = [self xFromDate:hourDate];

		CGContextSetShouldAntialias(c, 1);
		[hourString drawAtPoint:CGPointMake(hourX - (int) (hourStringSize.width / 2),
                                            (int) (hourStringSize.height / 2) - 5)
                       withAttributes:@{NSFontAttributeName:timeLabelFont}];
		CGContextSetShouldAntialias(c, 0);

        CGRect fretRect = CGRectMake(hourX - fretSize.width / 2, timeScaleHeight - 14, fretSize.width, fretSize.height);
        CGContextDrawImage(c, fretRect, fretImage.CGImage);
	}

	NSUInteger venueCount = [dataSource numberOfVenues];

    UIImage *starredImage = [UIImage imageNamed:@"timeline-starred.png"];
    UIImage *unstarredImage = [UIImage imageNamed:@"timeline-unstarred.png"];
    CGSize starSize = CGSizeMake(40, 40);

	for (NSUInteger i = 0; i < venueCount; i++) {

		int venueY = [delegate heightForTimeScale] + 1 + (int) (i * (venueHeight + 1));
		NSArray *gigs = [dataSource gigsForVenueAtIndex:i];

		for (Artist *gig in gigs) {

			int gigBeginX = [self xFromDate:gig.begin];
			int gigEndX = [self xFromDate:gig.end];
			int gigWidth = gigEndX - gigBeginX;
			CGRect gigRect = CGRectMake(gigBeginX, venueY + 6, gigWidth, venueHeight - 10);
            CGRect starRect = CGRectMake(gigBeginX + 2, (int) (venueY + (venueHeight - starSize.height) / 2) + 1, starSize.width, starSize.height);

			if (YES /* gig.favorite */) {

				CGContextSetFillColorWithColor(c, [UIColor colorWithRed:1.0f green:0.9f blue:0.7f alpha:0.4f].CGColor);
                CGContextFillRect(c, gigRect);

                if (gigWidth <= starSize.width + kMinWidthForArtistName) {
                    starRect.origin.x -= 3;
                }
                [starredImage drawInRect:starRect];

                CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);

                CGRect upperBorderRect = CGRectMake(gigBeginX, gigRect.origin.y - 1, gigWidth, 4);
                CGContextFillRect(c, upperBorderRect);

                CGRect lowerBorderRect = CGRectMake(gigBeginX, gigRect.origin.y+gigRect.size.height - 4, gigWidth, 4);
                CGContextFillRect(c, lowerBorderRect);

			} else {

				CGContextSetFillColorWithColor(c, [[[UIColor blackColor] colorWithAlphaComponent:0.4f] CGColor]);
                CGContextFillRect(c, gigRect);

                CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:1 alpha:0.7f] CGColor]);
                CGContextBeginPath(c);
                CGContextMoveToPoint(c, gigRect.origin.x, gigRect.origin.y);
                CGContextAddLineToPoint(c, gigRect.origin.x, gigRect.origin.y + gigRect.size.height);
                CGContextStrokePath(c);
                CGContextBeginPath(c);
                CGContextMoveToPoint(c, gigRect.origin.x + gigRect.size.width, gigRect.origin.y);
                CGContextAddLineToPoint(c, gigRect.origin.x + gigRect.size.width, gigRect.origin.y + gigRect.size.height);
                CGContextStrokePath(c);

                if (gigWidth <= starSize.width + kMinWidthForArtistName) {
                    starRect.origin.x -= 3;
                }
                [unstarredImage drawInRect:starRect];

                CGContextSetFillColorWithColor(c, [[UIColor whiteColor] CGColor]);
			}

            CGFloat textHeight = 16; // [gig.artistNameForTimelineDisplay sizeWithFont:artistLabelFont].height - 2;
            NSArray *artistTokens = [gig.artistName componentsSeparatedByString:@"\n"];
            NSUInteger tokenCount = [artistTokens count];

            CGContextSetShouldAntialias(c, 1);

			for (NSUInteger j = 0; j < tokenCount; j++) {
				NSString *token = artistTokens[j];
				CGFloat textWidth = [token sizeWithAttributes:@{NSFontAttributeName:artistLabelFont}].width;
				CGFloat xOffset = -textWidth / 2 + 12;
				CGFloat yOffset = -(textHeight * tokenCount) / 2 + (textHeight - 1) * j;
				CGContextSetShouldAntialias(c, 1);
				[token drawAtPoint:CGPointMake(gigBeginX + gigWidth / 2 + xOffset, venueY + venueHeight / 2 + yOffset) withAttributes:@{NSFontAttributeName:artistLabelFont}];
				CGContextSetShouldAntialias(c, 0);
			}
		}
	}

    NSDate *currentTime = [NSDate date];
    // just for testing: currentTime = [earliestHour dateByAddingTimeInterval:2.4*kOneHour];

    if ([currentTime after:earliestHour] && [currentTime before:[dataSource latestHour]]) {

        NSInteger currentTimeX = [self xFromDate:currentTime];

        CGContextSetStrokeColorWithColor(c, [[[UIColor redColor] colorWithAlphaComponent:0.9f] CGColor]);
        CGContextBeginPath(c);
        CGContextMoveToPoint(c, currentTimeX, 28);
        CGContextAddLineToPoint(c, currentTimeX, self.height - 10);
        CGContextStrokePath(c);

        CGContextSetShouldAntialias(c, 1);

        CGContextSetFillColorWithColor(c, [[[UIColor redColor] colorWithAlphaComponent:0.9f] CGColor]);
        CGContextBeginPath(c);
        CGContextMoveToPoint(c, currentTimeX, 29);
        CGContextAddLineToPoint(c, currentTimeX - 6, 16);
        CGContextAddLineToPoint(c, currentTimeX + 6, 16);
        CGContextClosePath(c);
        CGContextFillPath(c);
    }
}

- (NSInteger)xFromDate:(NSDate *)date
{
	NSTimeInterval dateDiff = [date timeIntervalSinceDate:[dataSource earliestHour]];
	return [self widthFromTimeInterval:dateDiff]-90;
}

- (NSInteger)widthFromTimeInterval:(NSTimeInterval)timeInterval
{
	return (NSInteger) ([delegate widthForOneHour] * (timeInterval/kOneHour));
}

#pragma mark UIResponder methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    pointOfBeginTouch = [[touches anyObject] locationInView:self];
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nextResponder touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		CGPoint touchPoint = [touch locationInView:self];
		CGFloat timeScaleHeight = [delegate heightForTimeScale];
		if (touchPoint.y > timeScaleHeight) {
			CGFloat venueRowHeight = [delegate heightForVenueRow];
			NSUInteger venueIndex = (NSUInteger) ((touchPoint.y - timeScaleHeight) / venueRowHeight);
			NSArray *gigs = [dataSource gigsForVenueAtIndex:venueIndex];
			for (Artist *gig in gigs) {
				CGFloat gigBeginX = [self xFromDate:gig.begin];
				CGFloat gigEndX = gigBeginX + [self widthFromTimeInterval:gig.duration];
				if (touchPoint.x >= gigBeginX && touchPoint.x <= gigBeginX + kStarAreaWidth) {
					[delegate gigFavoriteStatusToggled:gig];
					return;
				} else if (touchPoint.x >= gigBeginX && touchPoint.x <= gigEndX) {
                    [delegate gigSelected:gig];
                    return;
                }
			}
		}
	}

    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    float xDiff = (touchPoint.x - pointOfBeginTouch.x);
    float yDiff = (touchPoint.y - pointOfBeginTouch.y);
    if (fabs(yDiff) > fabs(xDiff) && fabs(yDiff) > [delegate heightForVenueRow] / 2) {
        [self playGroovyGuitarSound:((yDiff > 0) ? 1 : 2) volume:1.0];
        pointOfBeginTouch = touchPoint;
    }

	[self.nextResponder touchesEnded:touches withEvent:event];
}

#pragma mark -

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
    NSString *soundName = (soundNumber%2) ? @"Riff1" : @"Riff2";
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"aif"];

    self.currentPlayer = [self playerForSoundPath:soundPath];
    currentPlayer.volume = volume;
    [currentPlayer play];

    if (volume > 0) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

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
