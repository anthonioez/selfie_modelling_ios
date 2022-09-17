//
//  MainViewController.h
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GalleryViewController.h"

@class GADBannerView;

@interface MainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

- (IBAction)onShop:(id)sender;

- (IBAction)onPhoto50:(id)sender;
- (IBAction)onPhoto100:(id)sender;
- (IBAction)onPhoto200:(id)sender;
- (IBAction)onPhoto500:(id)sender;

- (IBAction)onVideo5:(id)sender;
- (IBAction)onVideo10:(id)sender;
- (IBAction)onVideo30:(id)sender;
- (IBAction)onVideo60:(id)sender;


@end
