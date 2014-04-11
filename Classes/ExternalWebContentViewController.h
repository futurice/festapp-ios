//
//  ExternalWebContentViewController.h
//  FestApp
//

#import <UIKit/UIKit.h>


@interface ExternalWebContentViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) NSURLRequest *request;

@end
