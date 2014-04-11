//
//  DayChooser.m
//  FestApp
//

#import "DayChooser.h"

@interface DayChooser () {

    UIView *buttonContainer;
    NSMutableArray *buttons;
}

@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) UIImage *unselectedImage;

@end

@implementation DayChooser

@synthesize selectedDayIndex;
@synthesize delegate;

- (id)initWithDayNames:(NSArray *)dayNames
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 29)];

    if (self) {

        self.backgroundColor = [UIColor clearColor];

        self.selectedImage = [[UIImage imageNamed:@"timeline_fri_sun_bg_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
        self.unselectedImage = [[UIImage imageNamed:@"timeline_fri_sun_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];

        _dayNames = dayNames;
        NSUInteger dayCount = [dayNames count];

        buttons = [NSMutableArray arrayWithCapacity:dayCount];

        buttonContainer = [[UIView alloc] init];
        buttonContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:buttonContainer];

        CGFloat fontPointSize = ([NSLocalizedString(@"lang", nil) isEqualToString:@"en"]) ? 16 : 14;

        for (NSUInteger i = 0; i < dayCount; i++) {

            NSString *dayName = dayNames[i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = (NSInteger) i;
            button.titleLabel.font = [UIFont boldSystemFontOfSize:fontPointSize];
            [button setTitle:dayName.uppercaseString forState:UIControlStateNormal];
            [button setTitleColor:kColorYellowLight forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];

            [buttons addObject:button];
            [buttonContainer addSubview:button];
        }

        if (buttons.count) {
            [self buttonPressed:buttons[0]];
        }
    }
    return self;
}


- (void)setSelectedDayIndex:(NSUInteger)index
{
    [self buttonPressed:buttons[index]];
}

- (IBAction)buttonPressed:(UIButton *)button
{
    selectedDayIndex = (NSUInteger)button.tag;

    NSUInteger buttonCount = [buttons count];
    int xTotal = 0;

    for (NSUInteger i = 0; i < buttonCount; i++) {

        UIButton *b = buttons[i];
        NSString *dayName = self.dayNames[i];

        if (selectedDayIndex == i) {

            [b setBackgroundImage:self.selectedImage forState:UIControlStateNormal];

        } else {

            [b setBackgroundImage:self.unselectedImage forState:UIControlStateNormal];
        }

        CGFloat buttonWidth = (int) (1.7 * [dayName sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}].width);
        button.frame = CGRectMake(xTotal, 0, buttonWidth, self.height);
        xTotal += buttonWidth - 3;
    }

    int xMargin = (int) (self.frame.size.width - xTotal) / 2;
    buttonContainer.frame = CGRectMake(xMargin, 0, xTotal, self.frame.size.height);

    [delegate dayChooser:self selectedDayWithIndex:selectedDayIndex];
}

@end
