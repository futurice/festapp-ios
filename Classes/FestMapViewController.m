//
//  FestMapViewController.m
//  FestApp
//
//  Created by Oleg Grenrus on 10/06/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import "FestMapViewController.h"

#import "FestDataManager.h"
#import "FestAppDelegate.h"

@interface FestMapViewController ()  <UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *mapView;

- (IBAction)doubleTap:(id)sender;
@end

@implementation FestMapViewController

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
    // minZoom
    CGFloat windowHeight = self.navigationController.view.frame.size.height;
    CGFloat navbarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    CGFloat viewportHeight = windowHeight - navbarHeight - statusHeight;

    CGFloat minZoomScale = MAX(viewportHeight / self.mapView.image.size.height,
                               self.scrollView.frame.size.width / self.mapView.image.size.height);
    
    self.scrollView.minimumZoomScale = minZoomScale;
    
    [self.scrollView setZoomScale:minZoomScale animated:NO];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:animated];

}

- (void)viewDidAppear:(BOOL)animated
{

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
