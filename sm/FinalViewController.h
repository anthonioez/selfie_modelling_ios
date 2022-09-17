//
//  FinalViewController.h
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinalViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property BOOL photo;
@property NSURL *videoUrl;

- (IBAction)onShop:(id)sender;

- (IBAction)onSessionView:(id)sender;
- (IBAction)onSessionNew:(id)sender;

@end
