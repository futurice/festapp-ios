//
//  CalloutView.m
//  FestApp
//

#import "CalloutView.h"

@interface CalloutView (hidden)

- (void)updateWidthByLabelContent;

@end

@implementation CalloutView

@synthesize leftView;
@synthesize centerView;
@synthesize rightView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize detailDisclosureButton;

@dynamic title;
@dynamic subtitle;
@dynamic showDetailDisclosureButton;

- (id)init
{
    self = [super initWithFrame:CGRectZero];

    if (self) {

        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.height = kCalloutHeight;

        self.centerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"callout-center.png"]];
        UIImage *leftStretchableImage = [[UIImage imageNamed:@"callout-left.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
        self.leftView = [[UIImageView alloc] initWithImage:leftStretchableImage];
        UIImage *rightStretchableImage = [[UIImage imageNamed:@"callout-right.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
        self.rightView = [[UIImageView alloc] initWithImage:rightStretchableImage];
        self.titleLabel = [[UILabel alloc] init];
        self.subtitleLabel = [[UILabel alloc] init];
        self.detailDisclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        subtitleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor blackColor];
        subtitleLabel.shadowColor = [UIColor blackColor];
        titleLabel.shadowOffset = CGSizeMake(0, -1);
        subtitleLabel.shadowOffset = CGSizeMake(0, -1);
        titleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.alpha = 0.8f;

        [self addSubview:leftView];
        [self addSubview:centerView];
        [self addSubview:rightView];
        [self addSubview:titleLabel];
        [self addSubview:subtitleLabel];
        [self addSubview:detailDisclosureButton];
    }

    return self;
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;

    CGFloat width = frame.size.width;
    int edgeViewWidth = (int) ((width - kCenterWidth) / 2);
    leftView.frame = CGRectMake(0, 0, edgeViewWidth, kCalloutBubbleHeight);
    centerView.frame = CGRectMake(edgeViewWidth, 0, kCenterWidth, kCalloutHeight);
    rightView.frame = CGRectMake(edgeViewWidth + kCenterWidth, 0, edgeViewWidth, kCalloutBubbleHeight);
    int labelWidth = (detailDisclosureButton.hidden) ?
                     ((int) width - 2 * kLabelEdgeMargin) :
                     ((int) width - kLabelEdgeMargin - kAccessoryButtonSize - kAccessoryButtonEdgeMargin);
    titleLabel.frame = CGRectMake(kLabelEdgeMargin, kTitleLabelY, labelWidth, kTitleLabelHeight);
    subtitleLabel.frame = CGRectMake(kLabelEdgeMargin, kSubtitleLabelY, labelWidth, kSubtitleLabelHeight);
    detailDisclosureButton.frame = CGRectMake(width - kAccessoryButtonSize - kAccessoryButtonEdgeMargin,
                                              (int) ((kCalloutBubbleHeight - kAccessoryButtonSize - 10) / 2),
                                              kAccessoryButtonSize, kAccessoryButtonSize);
}

- (void)updateWidthByLabelContent
{
    int titleWidth = (int) [titleLabel.text sizeWithAttributes:@{NSFontAttributeName:titleLabel.font}].width;
    int subtitleWidth = (int) [subtitleLabel.text sizeWithAttributes:@{NSFontAttributeName:subtitleLabel.font}].width;
    int biggestWidth = (titleWidth > subtitleWidth) ? titleWidth : subtitleWidth;
    int calloutWidth = (biggestWidth + kLabelEdgeMargin);
    if (detailDisclosureButton.hidden) {
        calloutWidth += kLabelEdgeMargin;
    } else {
        calloutWidth += kAccessoryButtonSize + 2 * kAccessoryButtonEdgeMargin;
    }

    if (calloutWidth > kMaxCalloutWidth) {
        calloutWidth = kMaxCalloutWidth;
    }

    [self setWidth:calloutWidth];
}

- (NSString *)title
{
    return titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    titleLabel.text = title;
    [self updateWidthByLabelContent];
}

- (NSString *)subtitle
{
    return subtitleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle
{
    subtitleLabel.text = subtitle;
    [self updateWidthByLabelContent];
}

- (BOOL)showDetailDisclosureButton
{
    return !detailDisclosureButton.hidden;
}

- (void)setShowDetailDisclosureButton:(BOOL)show
{
    detailDisclosureButton.hidden = !show;
    [self updateWidthByLabelContent];
}

- (void)setTargetOnButtonAction:(id)target withSelector:(SEL)selector
{
    [detailDisclosureButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}


@end
