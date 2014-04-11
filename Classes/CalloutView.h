//
//  CalloutView.h
//  FestApp
//

#import <UIKit/UIKit.h>

#define kCalloutHeight 65
#define kCalloutBubbleHeight 55
#define kCenterWidth 27
#define kTitleLabelY 4
#define kTitleLabelHeight 20
#define kSubtitleLabelY 24
#define kSubtitleLabelHeight 16
#define kAccessoryButtonSize 29
#define kLabelEdgeMargin 12
#define kAccessoryButtonEdgeMargin 10
#define kMaxCalloutWidth 200

@interface CalloutView : UIView

@property (strong, nonatomic) UIImageView *leftView;
@property (strong, nonatomic) UIImageView *centerView;
@property (strong, nonatomic) UIImageView *rightView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UIButton *detailDisclosureButton;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;
@property (assign, nonatomic) BOOL showDetailDisclosureButton;

- (void)setTargetOnButtonAction:(id)target withSelector:(SEL)selector;

@end
