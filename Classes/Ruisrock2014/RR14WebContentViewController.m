//
//  RR14WebContentViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14WebContentViewController.h"

#import "FestAppDelegate.h"
#import "FestDataManager.h"

@interface RR14WebContentViewController ()
@property (nonatomic, strong) NSString *content;
@end

@implementation RR14WebContentViewController

+ (RR14WebContentViewController *)newWithContent:(NSString *)content
{
    RR14WebContentViewController *controller = [[RR14WebContentViewController alloc] initWithNibName:@"RR14WebContentViewController" bundle:nil];
    [controller setContent:content];
    return controller;
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
                             "    div#main { "

                             "      font-family: HelveticaNeue-Light,HelveticaNeue, Helvetica; "
                             "      font-size: 15px;        "

                             "      margin-top: 10px;     "
                             "      margin-left: 10px;    "
                             "      margin-bottom: 10px;  "
                             "      margin-right: 10px;   "

                             "      padding-top: 1px;      "
                             "      padding-left: 0px;      "
                             "      padding-bottom: 10px;   "
                             "      padding-right: 0px;     "

                             //                             "      -webkit-box-shadow: 0px 2px 5px 1px #222; "

                             "    } "

                             "    h1, h2, h3 { "
                             "      font-family: HelveticaNeue-Light, HelveticaNeue, Helvetica; "
                             "    } "

                             "    b, strong { "
                             "      font-family: HelveticaNeue-Light, HelveticaNeue, Helvetica; "
                             "    } "

                             "    h1.title { "
                             "      font-size: 22px; "
                             "      font-weight: 200; "
                             "      text-align: left; "
                             "      margin-bottom: 20px; "
                             "      color: #000; /* previous known as red */"
                             "    } "

                             "    h2.subtitle { "
                             "      font-family: HelveticaNeue-Light,HelveticaNeue, Helvetica; "
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
    [html appendFormat:@"%@ ", self.content];
    [html appendString:@"</div> "];
    [html appendString:@"</body> "];
    [html appendString:@"</html> "];

    // NSLog(@"%@ loading html: %@", webView, html);
    [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://ruisrock.fi"]];

    self.navigationItem.leftBarButtonItem = [APPDELEGATE backBarButtonItem];
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

@end
