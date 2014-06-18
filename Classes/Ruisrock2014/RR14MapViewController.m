//
//  RR14MapViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "RR14MapViewController.h"

#import "FestDataManager.h"
#import "FestAppDelegate.h"

@interface RR14MapViewController ()
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
- (IBAction)doubleTap:(id)sender;
@end

@implementation RR14MapViewController

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

    self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    // minZoom
    CGFloat minZoomScale = MAX(self.scrollView.frame.size.height / self.mapView.image.size.height,
                               self.scrollView.frame.size.width / self.mapView.image.size.height);

    self.scrollView.minimumZoomScale = minZoomScale;

    [self.scrollView setZoomScale:minZoomScale animated:YES];
    [self.scrollView setContentOffset:CGPointMake(self.mapView.frame.size.width / 4, 0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIScrollViewDelegate   

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mapView;
}

#pragma mark Actions

- (IBAction)doubleTap:(id)sender
{
    CGFloat zoomScale = self.scrollView.zoomScale;
    if (zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:1.0f animated:YES];
    }
}

@end
