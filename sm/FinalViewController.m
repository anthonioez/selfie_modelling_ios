//
//  FinalViewController.m
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import "AppDelegate.h"
#import "FinalViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface FinalViewController ()

@end

@implementation FinalViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[Utils makeXibName:nibNameOrNil] bundle:nibBundleOrNil];
    if (self)
    {
        self.videoUrl = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    
    self.bannerView.adUnitID = ADMOB_BANNER_ID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onShop:(id)sender {
    [AppDelegate openShop];
}

- (IBAction)onSessionNew:(id)sender
{
    [AppDelegate resetSession];
    [[AppDelegate rootController] popToRootViewControllerAnimated:YES];
}

- (IBAction)onSessionView:(id)sender
{
    if(self.photo)
    {
        [self openGallery];
    }
    else
    {
        [self openVideo];
    }
}

- (void) openGallery
{
    if([[AppDelegate photos] count] == 0)
    {
        [Utils message:nil : @"No photos available!"];
        return;
    }
    
    GalleryViewController *localGallery = [[GalleryViewController alloc] initWithImages: [AppDelegate photos]];
    [self.navigationController pushViewController:localGallery animated:YES];
}

- (void) openVideo
{
    if(self.videoUrl == nil)
    {
        [Utils message:nil : @"Video session not found!"];
        return;
    }
    
    MPMoviePlayerViewController *mediaController = [[MPMoviePlayerViewController alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mediaController.moviePlayer];

    [mediaController.moviePlayer setMovieSourceType: MPMovieSourceTypeStreaming];
    [mediaController.moviePlayer setContentURL: self.videoUrl];
    [[AppDelegate rootController] presentMoviePlayerViewControllerAnimated: mediaController];
}

 // When the movie is done, release the controller.
-(void) moviePlaybackDidFinish: (NSNotification*) notification
{
    //[self dismissMoviePlayerViewControllerAnimated];

    [[NSNotificationCenter defaultCenter] removeObserver: self name: MPMoviePlayerPlaybackDidFinishNotification object: [notification object]];
}


@end
