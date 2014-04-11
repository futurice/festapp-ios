//
//  TimelineViewController.m
//  FestApp
//

#import "TimelineViewController.h"
#import "Gig.h"
#import "GigViewController.h"
#import "MapViewController.h"
#import "FestAppDelegate.h"
#import "NSDate+Additions.h"
#import "UIViewController+Additions.h"
#import "FestDataManager.h"

@interface TimelineViewController (hidden)

- (void)updateTimeline;
- (void)updateDaySelectionAnimated:(BOOL)animated;

@end

@implementation TimelineViewController

@synthesize gigsByDayThenByVenue;
@synthesize days;
@synthesize venues;

@synthesize selectedDay;
@synthesize earliestHour;
@synthesize latestHour;
@synthesize selectedVenue;

@synthesize timelineView;
@synthesize timelineScrollView;
@synthesize gigViewController;
@synthesize dayChooser;
@synthesize venueLabels;

- (void)setGigs:(NSArray *)theGigs withStages:(NSArray *)stages
{
	NSMutableDictionary *gigsDictByDayThenByVenue = [NSMutableDictionary dictionary];
	NSMutableArray *daysArr = [NSMutableArray array];
	NSMutableArray *venuesArr = [NSMutableArray array];

    for (NSDictionary *venueData in stages) {
        [venuesArr addObject:[venueData valueForKey:@"name"]];
    }

	for (Gig *gig in theGigs) {

		NSMutableDictionary *gigArraysByVenue = gigsDictByDayThenByVenue[gig.date];
		if (gigArraysByVenue == nil) {
			[daysArr addObject:gig.date];
			gigArraysByVenue = [NSMutableDictionary dictionary];
			gigsDictByDayThenByVenue[gig.date] = gigArraysByVenue;
		}

        NSString *shortVenue = nil;
        for (NSString *venue in venuesArr) {
            if ([gig.venue rangeOfString:venue].location == 0) {
                shortVenue = venue;
                break;
            }
        }

        if (shortVenue == nil) {
            NSLog(@"MISSING VENUE: %@", gig.venue);
        }

		NSMutableArray *gigsInVenue = gigArraysByVenue[shortVenue];
		if (gigsInVenue == nil && shortVenue != nil) {
			gigsInVenue = [NSMutableArray array];
			gigArraysByVenue[shortVenue] = gigsInVenue;
		}
		[gigsInVenue addObject:gig];
	}

    for (NSDate *day in daysArr) {
        NSMutableDictionary *gigArraysByVenue = gigsDictByDayThenByVenue[day];
        for (NSString *venue in venuesArr) {
            NSMutableArray *gigArray = gigArraysByVenue[venue];
            // Put the gigs in time order:
            if ([gigArray count] > 0) {
                gigArraysByVenue[venue] = [gigArray sortedArrayUsingSelector:@selector(compare:)];
            }
        }
    }

	self.gigsByDayThenByVenue = gigsDictByDayThenByVenue;
	self.days = [daysArr sortedArrayUsingSelector:@selector(compare:)];
	self.venues = venuesArr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Subscribe
    FestDataManager *dataManager = [FestDataManager sharedFestDataManager];

    RACSignal *gigsAndStagesSignal = [RACSignal combineLatest:@[[dataManager signalForResource:FestResourceArtists],
                                                                [dataManager signalForResource:FestResourceStages]]];

    [gigsAndStagesSignal subscribeNext:^(RACTuple *gigsAndStagesTuple) {
        [self setGigs:gigsAndStagesTuple.first withStages:gigsAndStagesTuple.second];
    }];

    NSMutableArray *dayNames = [NSMutableArray arrayWithCapacity:[days count]];
    for (NSDate *day in days) {
        [dayNames addObject:[day weekdayName]];
    }

    if (dayChooser) {
        [dayChooser removeFromSuperview];
        self.dayChooser = nil;
    }

    self.dayChooser = [[DayChooser alloc] initWithDayNames:dayNames];
    dayChooser.frame = CGRectMake(0, 12, 320, dayChooser.height);
    dayChooser.delegate = self;
    [self.view addSubview:dayChooser];
    dayChooser.selectedDayIndex = 0;
    selectedDayIndex = 1; // different than previous

    firstViewingSinceStartup = YES;

	timelineView.dataSource = self;
	timelineView.delegate = self;

    timelineScrollView.delegate = self;

    self.view.backgroundColor = [UIColor colorWithRed:0.94f green:0.77f blue:0.29f alpha:1];

    // TODO: move into signal handler
	NSUInteger venueCount = [venues count];
	CGFloat venueRowHeight = [self heightForVenueRow];
	CGFloat venueTextLabelWidth = [self widthForVenueLabel];

	UIImage *venueSlateImage = [UIImage imageNamed:@"timeline-venueslate.png"];
    CGFloat venueSlateTopMargin = (venueRowHeight - kVenueSlateHeight)/2;

    self.venueLabels = [NSMutableArray arrayWithCapacity:venueCount];

	for (NSUInteger i = 0; i <= venueCount; i++) {

		CGFloat venueLabelY = timelineScrollView.y + [self heightForTimeScale]+1 + i*(venueRowHeight+1);

		if (i < venueCount) {

			NSString *venue = venues[i];

			UIImageView *venueBackground = [[UIImageView alloc] initWithImage:venueSlateImage];
			venueBackground.frame = CGRectMake(0, venueLabelY+venueSlateTopMargin, [self widthForVenueLabel], kVenueSlateHeight);
			[self.view addSubview:venueBackground];

			UILabel *venueLabel = [[UILabel alloc] init];
			UIFont *venueFont = [UIFont fontWithName:@"Futura" size:13];
            venueLabel.font = venueFont;
			venueLabel.text = venue;
			venueLabel.textColor = [UIColor colorWithWhite:1 alpha:0.95f];
			venueLabel.backgroundColor = [UIColor clearColor];
			venueLabel.frame = CGRectMake(10, venueLabelY, venueTextLabelWidth, venueRowHeight);
			[self.view addSubview:venueLabel];
            [(NSMutableArray *) venueLabels addObject:venueLabel];

			UIButton *venueButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[venueButton setTitle:venue forState:UIControlStateNormal];
			[venueButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
			venueButton.frame = venueBackground.frame;
			[venueButton addTarget:self action:@selector(venueSelected:) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:venueButton];
		}
	}

	[self updateDaySelectionAnimated:NO];
    [self selectCurrentDayIfViable];

    if ([UIScreen mainScreen].bounds.size.height > 480) {
        self.backgroundView.image = [UIImage imageNamed:@"background_timeline-568h"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self.navigationItem performSelector:@selector(setTitle:) withObject:nil afterDelay:0.15];
    [self setSelectedVenue:selectedVenue];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFavoritingInstructionAlreadyShownKey]) {
        [self performSelector:@selector(showAlertWithMessage:) withObject:NSLocalizedString(@"gig.reminder.instruction", @"") afterDelay:1.1];
        [self performSelector:@selector(daySelected) withObject:nil afterDelay:1.3];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFavoritingInstructionAlreadyShownKey];
    }
    [timelineView setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabBarController sendEventToTracker:self.title];
    NSDate *currentDate = [NSDate date];
    NSDate *currentDay = [currentDate sameDateWithMidnightTimestamp];
    if ([currentDay isEqualToDate:selectedDay] && !firstViewingSinceStartup) {
        NSInteger currentDateX = [timelineView xFromDate:currentDate];
        if (currentDateX > 0 && currentDateX < timelineView.width) {
            [timelineScrollView setContentOffset:CGPointMake(currentDateX-kVenueSlateWidth-40, 0) animated:YES];
        }
    }
    if (firstViewingSinceStartup) {
        firstViewingSinceStartup = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setSelectedVenue:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)selectCurrentDayIfViable
{
    NSDate *currentDay = [[NSDate date] sameDateWithMidnightTimestamp];
    if ([days containsObject:currentDay]) {
        dayChooser.selectedDayIndex = [days indexOfObject:currentDay];
        [self daySelected];
    }
}

- (void)setSelectedDay:(NSDate *)newSelectedDay
{
    if (selectedDay != newSelectedDay) {
        selectedDay = newSelectedDay;
    }
    NSUInteger dayIndex = [days indexOfObject:selectedDay];
    if (dayChooser.selectedDayIndex != dayIndex) {
        dayChooser.selectedDayIndex = dayIndex;
        [self daySelected];
    }
}

- (void)setSelectedVenue:(NSString *)venue
{
    if (selectedVenue != nil && selectedVenue != venue) {
        UILabel *oldSelectedVenueLabel = venueLabels[[venues indexOfObject:selectedVenue]];
        [self beginFadingAnimationWithDuration:0.4 withView:oldSelectedVenueLabel];
        oldSelectedVenueLabel.textColor = [UIColor whiteColor];
    }
    selectedVenue = venue;
    if (selectedVenue != nil) {
        UILabel *selectedVenueLabel = venueLabels[[venues indexOfObject:selectedVenue]];
        [self beginFadingAnimationWithDuration:0.4 withView:selectedVenueLabel];
        selectedVenueLabel.textColor = [UIColor colorWithRed:0.94f green:0.77f blue:0.29f alpha:1];
    }
    [UIView commitAnimations];
}

- (IBAction)venueSelected:(UIButton *)button
{
	self.selectedVenue = button.titleLabel.text;

    MapViewController *mapViewController = ((FestAppDelegate *) [[UIApplication sharedApplication] delegate]).mapViewController;
    UIView *stageView = (mapViewController.stageViews)[[venues indexOfObject:selectedVenue]];
    [mapViewController performSelector:@selector(selectStageView:) withObject:stageView afterDelay:0.1];
    [self.tabBarController performSelector:@selector(setSelectedViewController:) withObject:mapViewController afterDelay:0.1];
}

- (IBAction)daySelected
{
    [self updateDaySelectionAnimated:YES];
}

- (void)updateDaySelectionAnimated:(BOOL)animated
{
    int direction = selectedDayIndex > dayChooser.selectedDayIndex ? -1 : 1;

    if (selectedDayIndex == dayChooser.selectedDayIndex) {
        [self updateTimeline];
        return;
    }

    selectedDayIndex = dayChooser.selectedDayIndex;
    self.selectedDay = days[dayChooser.selectedDayIndex];

    Gig *firstGigOfDay = nil;
    Gig *lastGigOfDay = nil;
    NSDictionary *gigsOfDayByVenue = gigsByDayThenByVenue[selectedDay];
    for (NSArray *gigsOfVenue in gigsOfDayByVenue.allValues) {
        for (Gig *gig in gigsOfVenue) {
            if (firstGigOfDay == nil || [gig.begin before:firstGigOfDay.begin]) {
                firstGigOfDay = gig;
            }
            if (lastGigOfDay == nil || [gig.end after:lastGigOfDay.end]) {
                lastGigOfDay = gig;
            }
        }
    }

    self.earliestHour = [firstGigOfDay.begin dateByAddingTimeInterval:-2*kOneHour];
    self.latestHour = [lastGigOfDay.end dateByAddingTimeInterval:kOneHour];

    int earliestHourMinutes = [earliestHour minute];
    if (earliestHourMinutes != 0) {
        self.earliestHour = [earliestHour dateByAddingTimeInterval:(60-earliestHourMinutes)*60];
    }

    int latestHourMinutes = [latestHour minute];
    if (latestHourMinutes != 0) {
        self.latestHour = [latestHour dateByAddingTimeInterval:(60-latestHourMinutes)*60-kOneHour];
    }

    NSLog(@"direction %d, earliest hour %@, latest hour %@", direction, self.earliestHour, self.latestHour);

    if (animated) {

        NSTimeInterval duration;
        if ((direction < 0 && timelineScrollView.contentOffset.x < timelineScrollView.contentSize.width/2) ||
            (direction > 0 && timelineScrollView.contentOffset.x > timelineScrollView.contentSize.width/2)) {
            duration = 0.7;
        } else {
            duration = 0.4;
        }

        [UIView animateWithDuration:duration animations:^{
            timelineView.frame = CGRectMake(direction * timelineView.width, 0, timelineView.width, timelineScrollView.height);
        } completion:^(BOOL finished) {
            [self bringUpdatedTimelineIntoView];
        }];

    } else {

        [self updateTimeline];
    }
}

- (void)updateTimeline
{
    NSTimeInterval timeSpan = [latestHour timeIntervalSinceDate:earliestHour];
	CGFloat timeSpanWidth = [self widthForOneHour] * ((CGFloat) timeSpan / kOneHour);

    int direction = 0;
    if (timelineView.x < 0) {
        direction = +1;
    } else if (timelineView.x > 320) {
        direction = -1;
    }

    // NSLog(@"earliest: %@, latest: %@, timespan: %f, width: %f", earliestHour, latestHour, timeSpan, timeSpanWidth);

    timelineView.frame = CGRectMake(direction*timeSpanWidth, 0, timeSpanWidth, timelineScrollView.height);
	timelineScrollView.contentSize = CGSizeMake(timelineView.width, 323);

	[timelineView reloadData];
}

- (void)bringUpdatedTimelineIntoView
{
    [self updateTimeline];

    if ([selectedDay isEqualToDate:[[NSDate date] sameDateWithMidnightTimestamp]]) {
        timelineScrollView.contentOffset = CGPointMake([timelineView xFromDate:[NSDate date]]-kVenueSlateWidth-40, 0);
    } else {
        timelineScrollView.contentOffset = CGPointMake([timelineView xFromDate:earliestHour], 0);
    }

    NSTimeInterval duration = (timelineView.x < 0) ? 0.7 : 0.4;
    [UIView animateWithDuration:duration animations:^{
        timelineView.frame = CGRectMake(0, 0, timelineView.width, timelineScrollView.height);
    }];
}

- (Gig *)nextGigForDate:(NSDate *)date onVenue:(NSString *)venue
{
    for (NSDate *day in days) {
        NSArray *gigsOfDay = [gigsByDayThenByVenue[day] valueForKey:venue];
        Gig *earliestGigStillToPlay = nil;
        for (Gig *gig in gigsOfDay) {
            if ([gig.end after:date] &&
                    (earliestGigStillToPlay == nil || [gig.begin before:earliestGigStillToPlay.begin])) {
                earliestGigStillToPlay = gig;
            }
        }
        if (earliestGigStillToPlay != nil) {
            return earliestGigStillToPlay;
        }
    }

    return nil;
}

- (void)scrollToGig:(Gig *)gig
{
    NSInteger gigBeginX = [timelineView xFromDate:gig.begin];
    NSInteger gigEndX = [timelineView xFromDate:gig.end];
    NSInteger scrollX = (gigBeginX+gigEndX)/2 - 180;
    [timelineScrollView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
}

#pragma mark TimelineViewDataSource

- (NSUInteger)numberOfVenues
{
   return venues.count;
}

- (NSArray *)gigsForVenueAtIndex:(NSUInteger)index
{
    if (index < venues.count) {
        return gigsByDayThenByVenue[selectedDay][venues[index]];
    } else {
        return nil;
    }
}

- (NSDate *)earliestHour
{
	return earliestHour;
}

- (NSDate *)latestHour
{
	return latestHour;
}

#pragma mark TimelineViewDelegate

- (NSInteger)heightForVenueRow
{
	return kVenueRowHeight;
}

- (NSInteger)widthForVenueLabel
{
	return kVenueSlateWidth;
}

- (NSInteger)heightForTimeScale
{
	return 52;
}

- (NSInteger)widthForOneHour
{
	return kHourWidth;
}

- (void)gigSelected:(Gig *)gig
{
    gigViewController.gig = gig;
    gigViewController.shouldFavoriteAllAlternatives = NO;
    self.navigationItem.title = NSLocalizedString(@"navigation.back", @"");
    [self.navigationController pushViewController:gigViewController animated:YES];
}

- (void)gigFavoriteStatusToggled:(Gig *)gig
{
	gig.favorite = !gig.favorite;
	[timelineView setNeedsDisplay];

    [self sendEventToTracker:[NSString stringWithFormat:@"star/timeline %d %@", gig.isFavorite, gig.artistName]];
}

#pragma mark - DayChooserDelegate

- (void)dayChooser:(DayChooser *)theDayChooser selectedDayWithIndex:(NSUInteger)dayIndex
{
    [self daySelected];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height > scrollView.height) {
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.height);
    }
}

@end
