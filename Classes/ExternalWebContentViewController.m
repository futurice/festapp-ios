//
//  ExternalWebContentViewController.m
//  FestApp
//

#import "ExternalWebContentViewController.h"

@interface ExternalWebContentViewController () <UIActionSheetDelegate>

@end

@implementation ExternalWebContentViewController

@synthesize webView;
@synthesize spinner;
@synthesize request;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;

    spinner.hidesWhenStopped = YES;

    if (iOS7) {
        webView.frame = CGRectMake(0, 64, 320, self.view.height - (64 + 44));
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [webView loadRequest:request];
    [spinner startAnimating];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (IBAction)actionButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"navigation.cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"link.copy", @""), NSLocalizedString(@"link.open", @""), nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [spinner stopAnimating];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"conn.problem", @"")
                                                    message:NSLocalizedString(@"conn.pagenotloaded", @"")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"navigation.ok", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [spinner stopAnimating];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            [[UIPasteboard generalPasteboard] setString:webView.request.URL.absoluteString];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"link.copied", @"") message:webView.request.URL.absoluteString delegate:self cancelButtonTitle:NSLocalizedString(@"navigation.ok", @"")
 otherButtonTitles:nil];
            [alert show];
        } else if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:webView.request.URL];
        }
    }
}

@end
