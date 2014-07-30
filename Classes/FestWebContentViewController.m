//
//  FestWebContentViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestWebContentViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"

@interface FestWebContentViewController () <UIWebViewDelegate>
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *contentTitle;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation FestWebContentViewController

- (id)initWithContent:(NSString *)content title:(NSString *)title
{
    self = [super initWithNibName:@"FestWebContentViewController" bundle:nil];
    if (self) {
        self.content = content;
        self.contentTitle = title;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableString *html = [@"<html> "
                             "<head> "
                             "  <style> "
                             "* { color: black; font-family: Palatino-Roman, HelveticaNeue-Light, HelveticaNeue, Helvetica; }"
                             "    html, body { "
                             "        margin:0;"
                             "        padding:0;"
                             "    } "

                             "    p { "
                             "        font-size:20px;"
                             "    } "
                             
                             "    div#main { "
                             "      font-size: 15px;        "

                             "      margin-top: 10px;     "
                             "      margin-left: 10px;    "
                             "      margin-bottom: 10px;  "
                             "      margin-right: 10px;   "

                             "      padding-top: 0px;      "
                             "      padding-left: 0px;      "
                             "      padding-bottom: 10px;   "
                             "      padding-right: 0px;     "   

                             "    } "

                             "    h1.title { "
                             "      font-size: 22px; "
                             "      font-weight: 200; "
                             "      text-align: left; "
                             "      margin-bottom: 20px; "
                             "    } "

                             "    h2.subtitle { "
                             "       "
                             "      color: #555; "
                             "      font-size: 13px; "
                             "      font-weight: normal; "
                             "      text-align: left; "
                             "      margin-top: -10px; "
                             "      margin-bottom: -2px; "
                             "    } "
                             "  </style> "
                             "</head>" mutableCopy];

    [html appendString:@"<body> "
     "<div id=\"main\"> "];
    if (self.contentTitle) {
        [html appendFormat:@"<h1>%@</h1>", self.contentTitle];
    }
    [html appendFormat:@"%@ ", self.content];
    [html appendString:@"</div> "];
    [html appendString:@"</body> "];
    [html appendString:@"</html> "];

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    // NSLog(@"%@ loading html: %@", webView, html);
    [self.webView loadHTMLString:html baseURL:baseURL];

    // swipe right to go back
    UISwipeGestureRecognizer *swipeGecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
    swipeGecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGecognizer];

    // back button
    self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate

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
            
        } else {
            [[UIApplication sharedApplication] openURL:[request URL]];
            return NO;
        }
    }
    
    return YES;
}

@end
