//
//  WebContentViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>


@interface WebContentViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *topCurtainView;

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

- (void)setWebTitle:(NSString *)title subtitle:(NSString *)subtitle content:(NSString *)content;

@end
