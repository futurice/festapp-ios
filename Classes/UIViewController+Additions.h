//
//  UIViewController+Additions.h
//  FestApp
//

#import <Foundation/Foundation.h>


@interface UIViewController (UIViewController_Additions)

- (void)beginFadingAnimationWithDuration:(NSTimeInterval)seconds withView:(UIView *)view;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void)showAlertWithMessage:(NSString *)message;
- (void)pop;
- (void)sendEventToTracker:(NSString *)event;

@end
