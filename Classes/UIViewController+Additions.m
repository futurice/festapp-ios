//
//  UIViewController+Additions.m
//  FestApp
//

#import "UIViewController+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIViewController (UIViewController_Additions)

- (void)beginFadingAnimationWithDuration:(NSTimeInterval)seconds withView:(UIView *)view
{
	CATransition *transition = [CATransition animation];
    transition.duration = seconds;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [view.layer addAnimation:transition forKey:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"button.ok", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)showAlertWithMessage:(NSString *)message
{
    [self showAlertWithTitle:nil message:message];
}

- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendEventToTracker:(NSString *)event
{
    NSLog(@"tracked event: %@", event);
}

@end
