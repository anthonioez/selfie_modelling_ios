//
//  FGalleryPhotoView.h
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol FGalleryPhotoViewDelegate;

//@interface FGalleryPhotoView : UIImageView {
@interface FGalleryPhotoView : UIScrollView <UIScrollViewDelegate>
	
@property (nonatomic,strong) id <FGalleryPhotoViewDelegate> photoDelegate;

@property UIImageView *imageView;
@property UIActivityIndicatorView *activity;
@property UIButton *button;
@property BOOL isZoomed;
@property NSTimer *tapTimer;

// inits this view to have a button over the image
- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

- (void)resetZoom;

- (UIImage*)createHighlightImageWithFrame:(CGRect)rect;
- (void)killActivityIndicator;
- (void)startTapTimer;
- (void)stopTapTimer;

@end



@protocol FGalleryPhotoViewDelegate

// indicates single touch and allows controller repsond and go toggle fullscreen
- (void)didTapPhotoView:(FGalleryPhotoView*)photoView;

@end

