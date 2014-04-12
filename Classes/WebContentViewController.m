//
//  WebContentViewController.m
//  FestApp
//

#import "WebContentViewController.h"
#import "ExternalWebContentViewController.h"
#import "UIViewController+Additions.h"

@interface WebContentViewController () {

    NSString *webTitle;
    NSString *webSubtitle;
    NSString *webContent;
}

@end

@implementation WebContentViewController

@synthesize webView;
@synthesize scrollView;

@synthesize edgeInsets;

- (void)viewDidLoad
{
    [super viewDidLoad];

    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.userInteractionEnabled = YES;
    webView.delegate = self;
    webView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;

    if ([[webView subviews] count] > 0) {
        for (UIView *shadowView in [[webView subviews][0] subviews]) {
            [shadowView setHidden:YES];
        }

        // unhide the last view so it is visible again because it has the content
        [[[[webView subviews][0] subviews] lastObject] setHidden:NO];
    }

    if ([webView respondsToSelector:@selector(scrollView)]) {
        self.scrollView = webView.scrollView;
    } else {
        for (UIView *subview in webView.subviews) {
            if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
                self.scrollView = ((UIScrollView *) subview);
                break;
            }
        }
    }

    scrollView.delegate = self;

    self.edgeInsets = UIEdgeInsetsMake(12, 12, 20, 12);

    UISwipeGestureRecognizer *swipeGecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pop)];
    swipeGecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGecognizer];

    if (iOS7) {
        self.webView.frame = CGRectMake(0, 64, 320, self.view.height - (64 + 44));
        self.topCurtainView.y = 64;
        self.backgroundView.y = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationItem performSelector:@selector(setTitle:) withObject:nil afterDelay:0.15];

    NSMutableString *html = [NSMutableString stringWithFormat:@"<html> "
                             "<head> "
                             "  <style> "
                             "    div#main { "
                             
                             "      font-family: HelveticaNeue-Light, Helvetica; "
                             "      font-size: 14px;        "
                             
                             "      margin-top: %.0fpx;     "
                             "      margin-left: %.0fpx;    "
                             "      margin-bottom: %.0fpx;  "
                             "      margin-right: %.0fpx;   "
                             
                             "      padding-top: 1px;      "
                             "      padding-left: 0px;      "
                             "      padding-bottom: 10px;   "
                             "      padding-right: 0px;     "
                             
//                             "      -webkit-box-shadow: 0px 2px 5px 1px #222; "
                             
                             "    } "
                             
                             "    h1, h2, h3 { "
                             "      font-family: HelveticaNeue-Light, Helvetica; "
                             "    } "
                             
                             "    b, strong { "
                             "      font-family: HelveticaNeue-Light, Helvetica; "
                             "    } "
                             
                             "    h1.title { "
                             "      font-size: 22px; "
                             "      font-weight: normal; "
                             "      text-align: left; "
                             "      margin-bottom: 20px; "
                             "      color: #000; /* previous known as red */"
                             "    } "
                             
                             "    h2.subtitle { "
                             "      font-family: HelveticaNeue-Light, Helvetica; "
                             "      color: #555; "
                             "      font-size: 20px; "
                             "      font-weight: normal; "
                             "      text-align: center; "
                             "      margin-top: -10px; "
                             "      margin-bottom: -2px; "
                             "    } "
                             "  </style> "
                             "</head>", edgeInsets.top, edgeInsets.left, edgeInsets.bottom, edgeInsets.right];

    [html appendString:@"<body> "
     "<div id=\"main\"> "];
    if (webTitle != nil) {
        [html appendFormat:@"<h1 class=\"title\">%@</h1> ", webTitle];
    }
    if (webSubtitle != nil) {
        [html appendFormat:@"<h2 class=\"subtitle\">%@</h2> ", webSubtitle];
    }
    [html appendFormat:@"%@ ", webContent];
    [html appendString:@"</div> "];
    [html appendString:@"</body> "];
    [html appendString:@"</html> "];

    // NSLog(@"%@ loading html: %@", webView, html);
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://ruisrock.fi"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabBarController sendEventToTracker:webTitle];
}

- (NSString *)webContent
{
    return webContent;
}

- (void)setWebTitle:(NSString *)title subtitle:(NSString *)subtitle content:(NSString *)content
{
    if (content != nil) {
        content = [self html:content byTrimmingTag:@"iframe" includesEndTag:YES];
        content = [self html:content byTrimmingTag:@"table" includesEndTag:YES];
        content = [self html:content byTrimmingTag:@"object" includesEndTag:YES];
        content = [self html:content byTrimmingTag:@"img" includesEndTag:NO];
        content = [content stringByReplacingOccurrencesOfString:@" style=\"font-family: mceinline;\"" withString:@""];
    }

    // NSLog(@"setting web content: %@", content);
    webTitle = title;
    webSubtitle = subtitle;
    webContent = content;

    [scrollView setContentOffset:CGPointZero animated:NO];
}

- (NSString *)html:(NSString *)html byTrimmingTag:(NSString *)tag includesEndTag:(BOOL)includesEndTag
{
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *text = nil;

    NSString *beginTag = [NSString stringWithFormat:@"<%@", tag];
    NSString *endTag = (includesEndTag) ? [NSString stringWithFormat:@"/%@>", tag] : @">";

    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:beginTag intoString:NULL];
        [scanner scanUpToString:endTag intoString:&text];

        if (text != nil) {
            NSString *removable = [text stringByAppendingString:endTag];
            // NSLog(@"trimmed: %@", removable);
            html = [html stringByReplacingOccurrencesOfString:removable withString:@""];
        }
    }

    return html;
}

- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    scrollView.contentSize = CGSizeMake(scrollView.width, scrollView.contentSize.height);
}

- (BOOL)webView:(UIWebView *)theWebView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {

        NSString *link = [[request URL] absoluteString];
        NSLog(@"%@", link);

        if ([link rangeOfString:@"itms-apps://"].location != NSNotFound) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }

        if ([link rangeOfString:@"tel:"].location == 0) {

            return YES;

        } else if ([link rangeOfString:@"http"].location == NSNotFound) {

            NSURL *baseURL = [NSURL URLWithString:@"http://www.ruisrock.fi"];
            request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[link substringFromIndex:[link rangeOfString:@"/index.php?"].location] relativeToURL:baseURL]];
        }

        ExternalWebContentViewController *linkViewer = [[ExternalWebContentViewController alloc] init];
        self.navigationItem.title = NSLocalizedString(@"navigation.back", @"");
        linkViewer.request = request;
        [self.navigationController pushViewController:linkViewer animated:YES];

        return NO;

    }

    return YES;
}

@end
