    //
//  FGalleryViewController.m
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "GalleryViewController.h"

#define kThumbnailSize 75
#define kThumbnailSpacing 4
#define kCaptionPadding 3
#define kToolbarHeight 40


@interface GalleryViewController ()
{
    BOOL useThumbnailView;
    BOOL beginsInThumbnailView;
    
    BOOL isActive;
    BOOL isFullscreen;
    BOOL isScrolling;
    BOOL isThumbViewShowing;
    
    CGRect scrollerRect;
    NSString *galleryID;
    NSInteger currentIndex;
    NSInteger startingIndex;
    

    
    NSMutableDictionary *photoLoaders;
    NSMutableArray *photoThumbnailViews;
    NSMutableArray *photoViews;
    
    NSMutableArray *photoList;
}
@end



@implementation GalleryViewController

#pragma mark - Public Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if((self = [super initWithNibName:nil bundle:nil])) {
	
		// init gallery id with our memory address
		galleryID						= [NSString stringWithFormat:@"%p", self];

        // configure view controller
		self.hidesBottomBarWhenPushed		= YES;
        
        // set defaults
        useThumbnailView                   = YES;
		_prevStatusStyle					= [[UIApplication sharedApplication] statusBarStyle];
		
		// create storage objects
		currentIndex						= 0;
        startingIndex                      = 0;
		photoLoaders						= [[NSMutableDictionary alloc] init];
		photoViews							= [[NSMutableArray alloc] init];
		photoThumbnailViews				= [[NSMutableArray alloc] init];
        
        /*
         // debugging: 
         self.containerView.layer.borderColor = [[UIColor yellowColor] CGColor];
         self.containerView.layer.borderWidth = 1.0;
         
         _innerContainer.layer.borderColor = [[UIColor greenColor] CGColor];
         _innerContainer.layer.borderWidth = 1.0;
         
         _scroller.layer.borderColor = [[UIColor redColor] CGColor];
         _scroller.layer.borderWidth = 2.0;
         */
	}
	return self;
}
- (id)initWithImages: (NSMutableArray *)images
{
    if((self = [self initWithNibName:@"GalleryViewController" bundle:nil])) {
        
        photoList = images;
    }
    return self;
}

#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    NSLog(@"[FGalleryViewController] didReceiveMemoryWarning! clearing out cached images...");
    // unload fullsize and thumbnail images for all our images except at the current index.
    NSArray *keys = [photoLoaders allKeys];
    NSUInteger i, count = [keys count];
    if (isThumbViewShowing==YES) {
        for (i = 0; i < count; i++)
        {
            FGalleryPhoto *photo = [photoLoaders objectForKey:[keys objectAtIndex:i]];
            [photo unloadFullsize];
            
            // unload main image thumb
            FGalleryPhotoView *photoView = [photoViews objectAtIndex:i];
            photoView.imageView.image = nil;
        }
    } else {
        for (i = 0; i < count; i++)
        {
            if( i != currentIndex )
            {
                FGalleryPhoto *photo = [photoLoaders objectForKey:[keys objectAtIndex:i]];
                [photo unloadFullsize];
                
                // unload main image thumb
                FGalleryPhotoView *photoView = [photoViews objectAtIndex:i];
                photoView.imageView.image = nil;
                
                // unload thumb tile
                photoView = [photoThumbnailViews objectAtIndex:i];
                photoView.imageView.image = nil;
            }
        }
    }
}


- (void)dealloc {
    
    // remove KVO listener
    [self.view removeObserver:self forKeyPath:@"frame"];
    
    // Cancel all photo loaders in progress
    NSArray *keys = [photoLoaders allKeys];
    NSUInteger i, count = [keys count];
    for (i = 0; i < count; i++) {
        FGalleryPhoto *photo = [photoLoaders objectForKey:[keys objectAtIndex:i]];
        photo.delegate = nil;
        [photo unloadFullsize];
    }
    
    galleryID = nil;
    
    [photoLoaders removeAllObjects];
    photoLoaders = nil;
    
    [photoThumbnailViews removeAllObjects];
    photoThumbnailViews = nil;
    
    [photoViews removeAllObjects];
    photoViews = nil;
}

#pragma mark - View Loading
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;

    // create public objects first so they're available for custom configuration right away. positioning comes later.

    self.toolBar.barStyle					= UIBarStyleBlackTranslucent;
    
    // listen for container frame changes so we can properly update the layout during auto-rotation or going in and out of fullscreen
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

    // setup scroller
    self.scrollerView.delegate							= self;
    self.scrollerView.pagingEnabled						= YES;
    self.scrollerView.showsVerticalScrollIndicator		= NO;
    self.scrollerView.showsHorizontalScrollIndicator	= NO;
    self.scrollerView.autoresizesSubviews				= NO;
    
    // make things flexible
    //self.containerView.autoresizingMask					= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // setup thumbs view
    self.thumbnailView.hidden							= YES;
    self.thumbnailView.contentInset                     = UIEdgeInsetsMake( kThumbnailSpacing, kThumbnailSpacing, kThumbnailSpacing, kThumbnailSpacing);
    
    // build stuff
    [self reloadGallery];
    
    
    self.bannerView.adUnitID = ADMOB_BANNER_ID;
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}

- (void)viewDidUnload {
    
    [self destroyViews];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    isActive = YES;
    
    self.useThumbnailView = useThumbnailView;
    
    // toggle into the thumb view if we should start there
    if (beginsInThumbnailView && useThumbnailView) {
        [self showThumbnailViewWithAnimation:NO];
        [self loadAllThumbViewPhotos];
    }
    
    [self layoutViews];
    
    // update status bar to be see-through
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    
    // init with next on first run.
    if( currentIndex == -1 )
        [self onNext: nil];
    else
        [self gotoImageByIndex:currentIndex animated:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    isActive = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:_prevStatusStyle animated:animated];
}

#pragma mark - IBActions
- (IBAction)onNext:(id)sender
{
    NSUInteger numberOfPhotos = [photoList count];
    NSUInteger nextIndex = currentIndex+1;
    
    // don't continue if we're out of images.
    if( nextIndex <= numberOfPhotos )
    {
        [self gotoImageByIndex:nextIndex animated:NO];
    }
}

- (IBAction)onPrev:(id)sender
{
    NSUInteger prevIndex = currentIndex-1;
    [self gotoImageByIndex:prevIndex animated:NO];
}

- (void)onBack:(id)sender
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

- (void)onSeeAll:(id)sender
{
    // show thumb view
    [self toggleThumbnailViewWithAnimation:YES];
    
    // tell thumbs that havent loaded to load
    [self loadAllThumbViewPhotos];
}

- (IBAction)onThumbClick:(id)sender
{
    FGalleryPhotoView *photoView = (FGalleryPhotoView*)[(UIButton*)sender superview];
    [self hideThumbnailViewWithAnimation:YES];
    [self gotoImageByIndex:photoView.tag animated:NO];
}

#pragma mark - Functions

- (void)destroyViews {
    // remove previous photo views
    for (UIView *view in photoViews) {
        [view removeFromSuperview];
    }
    [photoViews removeAllObjects];
    
    // remove previous thumbnails
    for (UIView *view in photoThumbnailViews) {
        [view removeFromSuperview];
    }
    [photoThumbnailViews removeAllObjects];
    
    // remove photo loaders
    NSArray *photoKeys = [photoLoaders allKeys];
    for (int i=0; i<[photoKeys count]; i++) {
        FGalleryPhoto *photoLoader = [photoLoaders objectForKey:[photoKeys objectAtIndex:i]];
        photoLoader.delegate = nil;
        [photoLoader unloadFullsize];
    }
    [photoLoaders removeAllObjects];
}


- (void)reloadGallery
{
    currentIndex = startingIndex;
    isThumbViewShowing = NO;
    
    // remove the old
    [self destroyViews];
    
    // build the new
    if ([photoList count] > 0) {
        // create the image views for each photo
        [self buildViews];
        
        // create the thumbnail views
        [self buildThumbsViewPhotos];
        
        // start loading thumbs
        [self preloadThumbnailImages];
        
        // start on first image
        [self gotoImageByIndex:currentIndex animated:NO];
        
        // layout
        [self layoutViews];
    }
}

- (FGalleryPhoto*)currentPhoto
{
    return [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)currentIndex]];
}


- (void)resizeImageViewsWithRect:(CGRect)rect
{
	// resize all the image views
	NSUInteger i, count = [photoViews count];
	float dx = 0;
	for (i = 0; i < count; i++) {
		FGalleryPhotoView * photoView = [photoViews objectAtIndex:i];
		photoView.frame = CGRectMake(dx, 0, rect.size.width, rect.size.height );
		dx += rect.size.width;
	}
}


- (void)resetImageViewZoomLevels
{
	// resize all the image views
	NSUInteger i, count = [photoViews count];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView * photoView = [photoViews objectAtIndex:i];
		[photoView resetZoom];
	}
}


- (void)removeImageAtIndex:(NSUInteger)index
{
	// remove the image and thumbnail at the specified index.
	FGalleryPhotoView *imgView = [photoViews objectAtIndex:index];
 	FGalleryPhotoView *thumbView = [photoThumbnailViews objectAtIndex:index];
	FGalleryPhoto *photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i",(int)index]];
	
	[photo unloadFullsize];
	
	[imgView removeFromSuperview];
	[thumbView removeFromSuperview];
	
	[photoViews removeObjectAtIndex:index];
	[photoThumbnailViews removeObjectAtIndex:index];
	[photoLoaders removeObjectForKey:[NSString stringWithFormat:@"%i",(int)index]];
	
	[self layoutViews];
	[self updateButtons];
    [self updateTitle];
}


- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated
{
	NSUInteger numPhotos = [photoList count];
	
	// constrain index within our limits
    if( index >= numPhotos ) index = numPhotos - 1;
	
	
	if( numPhotos == 0 ) {
		
		// no photos!
		currentIndex = -1;
	}
	else {
		
		// clear the fullsize image in the old photo
		[self unloadFullsizeImageWithIndex:currentIndex];
		
		currentIndex = index;
		[self moveScrollerToCurrentIndexWithAnimation:animated];
		[self updateTitle];
		
		if( !animated )	{
			[self preloadThumbnailImages];
			[self loadFullsizeImageWithIndex:index];
		}
	}
	[self updateButtons];
}


- (void)layoutViews
{
	[self updateScrollSize];
	[self resizeImageViewsWithRect:self.scrollerView.frame];

	[self arrangeThumbs];
	[self moveScrollerToCurrentIndexWithAnimation:NO];
}


- (void)setUseThumbnailView:(BOOL)useThumbnailV
{
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Back", @"") style: UIBarButtonItemStyleBordered target:self action:@selector(onBack:)];
    [self.navItem setLeftBarButtonItem: newBackButton];
    
    useThumbnailView = useThumbnailV;
    if( self.navigationController ) {
        if (useThumbnailView) {
            UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"See all", @"") style:UIBarButtonItemStylePlain target:self action:@selector(onSeeAll:)] ;
            [self.navItem setRightBarButtonItem:btn animated:YES];
        }
        else {
            [self.navItem setRightBarButtonItem:nil animated:NO];
        }
    }
}


#pragma mark - Private Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"frame"]) 
	{
		[self layoutViews];
	}
}

- (void)enterFullscreen
{
    if (!isThumbViewShowing)
    {
        isFullscreen = YES;
        
        [self disableApp];
        
        UIApplication* application = [UIApplication sharedApplication];
        if ([application respondsToSelector: @selector(setStatusBarHidden:withAnimation:)]) {
            [[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation: UIStatusBarAnimationFade]; // 3.2+
        } else {
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] setStatusBarHidden: YES animated:YES]; // 2.0 - 3.2
    #pragma GCC diagnostic warning "-Wdeprecated-declarations"
        }
        
        [UIView beginAnimations:@"galleryOut" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(enableApp)];
        
        self.toolBar.alpha = 0.0;
        self.navBar.alpha = 0.0;
        [UIView commitAnimations];
    }
}


- (void)exitFullscreen
{
	isFullscreen = NO;
    
	[self disableApp];
    
	UIApplication* application = [UIApplication sharedApplication];
	if ([application respondsToSelector: @selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; // 3.2+
	} else {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO]; // 2.0 - 3.2
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
	}

    
	[UIView beginAnimations:@"galleryIn" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(enableApp)];
	self.toolBar.alpha = 1.0;
    self.navBar.alpha = 1.0;

	[UIView commitAnimations];
}

- (void)enableApp
{
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void)disableApp
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}


- (void)didTapPhotoView:(FGalleryPhotoView*)photoView
{
	// don't change when scrolling
	if( isScrolling || !isActive ) return;
	
	// toggle fullscreen.
	if( isFullscreen == NO ) {
		
		[self enterFullscreen];
	}
	else {
		
		[self exitFullscreen];
	}

}

- (void)updateScrollSize
{
	float contentWidth = self.scrollerView.frame.size.width * [photoList count];
	[self.scrollerView setContentSize:CGSizeMake(contentWidth, self.scrollerView.frame.size.height)];
}

- (void)updateTitle
{
    [self.navItem setTitle:[NSString stringWithFormat:@"%i %@ %i", (int)currentIndex+1, NSLocalizedString(@"of", @"") , (int)[photoList count]]];
}


- (void)updateButtons
{
	self.prevButton.enabled = ( currentIndex <= 0 ) ? NO : YES;
	self.nextButton.enabled = ( currentIndex >= [photoList count]-1 ) ? NO : YES;
}

- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation
{
	int xp = self.scrollerView.frame.size.width * currentIndex;
	[self.scrollerView scrollRectToVisible:CGRectMake(xp, 0, self.scrollerView.frame.size.width, self.scrollerView.frame.size.height) animated:animation];
	isScrolling = animation;
}


// creates all the image views for this gallery
- (void)buildViews
{
	NSUInteger i, count = [photoList count];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView *photoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero];
		photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		photoView.autoresizesSubviews = YES;
        photoView.photoDelegate = self;
		[self.scrollerView addSubview:photoView];
		[photoViews addObject:photoView];
	}
}


- (void)buildThumbsViewPhotos
{
	NSUInteger i, count = [photoList count];
	for (i = 0; i < count; i++) {
		
		FGalleryPhotoView *thumbView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero target:self action:@selector(onThumbClick:)];
		[thumbView setContentMode:UIViewContentModeScaleAspectFill];
		[thumbView setClipsToBounds:YES];
		[thumbView setTag:i];
        
		[self.thumbnailView addSubview:thumbView];
		
        [photoThumbnailViews addObject:thumbView];
	}
}



- (void)arrangeThumbs
{
	float dx = 0.0;
	float dy = 0.0;
	// loop through all thumbs to size and place them
	NSUInteger i, count = [photoThumbnailViews count];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView *thumbView = [photoThumbnailViews objectAtIndex:i];
		[thumbView setBackgroundColor:[UIColor grayColor]];
		
		// create new frame
		thumbView.frame = CGRectMake( dx, dy, kThumbnailSize, kThumbnailSize);
		
		// increment position
		dx += kThumbnailSize + kThumbnailSpacing;
		
		// check if we need to move to a different row
		if( dx + kThumbnailSize + kThumbnailSpacing > self.thumbnailView.frame.size.width - kThumbnailSpacing )
		{
			dx = 0.0;
			dy += kThumbnailSize + kThumbnailSpacing;
		}
	}
	
	// set the content size of the thumb scroller
	[self.thumbnailView setContentSize:CGSizeMake( self.thumbnailView.frame.size.width - ( kThumbnailSpacing*2 ), dy + kThumbnailSize + kThumbnailSpacing )];
}

#pragma mark - Animations
- (void)toggleThumbnailViewWithAnimation:(BOOL)animation
{
    [self.navItem setTitle: @""];
    if (isThumbViewShowing)
        [self hideThumbnailViewWithAnimation:animation];
    else
        [self showThumbnailViewWithAnimation:animation];
    
    [self.toolBar setHidden: isThumbViewShowing];
}


- (void)showThumbnailViewWithAnimation:(BOOL)animation
{
    isThumbViewShowing = YES;
    
    [self arrangeThumbs];
    [self.navItem.rightBarButtonItem setTitle:NSLocalizedString(@"View", @"")];
    
    if (animation)
    {
        // do curl animation
        [UIView beginAnimations:@"uncurl" context:nil];
        [UIView setAnimationDuration:.500];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.thumbnailView cache:YES];
        [self.thumbnailView setHidden:NO];
        [self.scrollerView setHidden: YES];
        [UIView commitAnimations];
    }
    else
    {
        [self.thumbnailView setHidden:NO];
        [self.scrollerView setHidden: YES];
    }
}


- (void)hideThumbnailViewWithAnimation:(BOOL)animation
{
    isThumbViewShowing = NO;
    [self.navItem.rightBarButtonItem setTitle:NSLocalizedString(@"All", @"")];
    
    if (animation)
    {
        // do curl animation
        [UIView beginAnimations:@"curl" context:nil];
        [UIView setAnimationDuration:.500];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.thumbnailView cache:YES];
        [self.thumbnailView setHidden:YES];
        [self.scrollerView setHidden: NO];
        [UIView commitAnimations];
    }
    else
    {
        [self.thumbnailView setHidden:NO];
        [self.scrollerView setHidden: YES];
    }
}


#pragma mark - Image Loading
- (void)preloadThumbnailImages
{
	NSUInteger index = currentIndex;
	NSUInteger count = [photoViews count];
    
	// make sure the images surrounding the current index have thumbs loading
	NSUInteger nextIndex = index + 1;
	NSUInteger prevIndex = index - 1;
	
	// the preload count indicates how many images surrounding the current photo will get preloaded.
	// a value of 2 at maximum would preload 4 images, 2 in front of and two behind the current image.
	NSUInteger preloadCount = 1;
	
	FGalleryPhoto *photo;
	
	// check to see if the current image thumb has been loaded
	photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	
	if( !photo )
	{
		[self loadThumbnailImageWithIndex:index];
		photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	}
	
	if( !photo.hasThumbLoaded && !photo.isThumbLoading )
	{
		[photo loadThumbnail];
	}
	
	NSUInteger curIndex = prevIndex;
	while( curIndex > -1 && curIndex > prevIndex - preloadCount )
	{
		photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)curIndex]];
		
		if( !photo ) {
			[self loadThumbnailImageWithIndex:curIndex];
			photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)curIndex]];
		}
		
		if( !photo.hasThumbLoaded && !photo.isThumbLoading )
		{
			[photo loadThumbnail];
		}
		
		curIndex--;
	}
	
	curIndex = nextIndex;
	while( curIndex < count && curIndex < nextIndex + preloadCount )
	{
		photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)curIndex]];
		
		if( !photo ) {
			[self loadThumbnailImageWithIndex:curIndex];
			photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)curIndex]];
		}
		
		if( !photo.hasThumbLoaded && !photo.isThumbLoading )
		{
			[photo loadThumbnail];
		}
		
		curIndex++;
	}
}


- (void)loadAllThumbViewPhotos
{
	NSUInteger i, count = [photoList count];
	for (i=0; i < count; i++) {
		
		[self loadThumbnailImageWithIndex:i];
	}
}


- (void)loadThumbnailImageWithIndex:(NSUInteger)index
{
	FGalleryPhoto *photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	
	if( photo == nil )
		photo = [self createGalleryPhotoForIndex:index];
	
	[photo loadThumbnail];
}


- (void)loadFullsizeImageWithIndex:(NSUInteger)index
{
	FGalleryPhoto *photo = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
	
	if( photo == nil )
		photo = [self createGalleryPhotoForIndex:index];
	
	[photo loadFullsize];
}


- (void)unloadFullsizeImageWithIndex:(NSUInteger)index
{
	if (index < [photoViews count]) {		
		FGalleryPhoto *loader = [photoLoaders objectForKey:[NSString stringWithFormat:@"%i", (int)index]];
		[loader unloadFullsize];
		
		FGalleryPhotoView *photoView = [photoViews objectAtIndex:index];
		photoView.imageView.image = loader.thumbnail;
	}
}


- (FGalleryPhoto*)createGalleryPhotoForIndex:(NSUInteger)index
{

	NSString *path = [photoList objectAtIndex:index];

    FGalleryPhoto *photo = [[FGalleryPhoto alloc] initWithThumbnailPath:path fullsizePath:path delegate:self] ;
    photo.tag = index;
	[photoLoaders setObject:photo forKey: [NSString stringWithFormat:@"%i", (int)index]];
	
	return photo;
}


- (void)scrollingHasEnded {
	
	isScrolling = NO;
	
	NSUInteger newIndex = floor( self.scrollerView.contentOffset.x / self.scrollerView.frame.size.width );
	
	// don't proceed if the user has been scrolling, but didn't really go anywhere.
	if( newIndex == currentIndex )
		return;
	
	// clear previous
	[self unloadFullsizeImageWithIndex:currentIndex];
	
	currentIndex = newIndex;
    [self updateTitle];
	[self updateButtons];
	[self loadFullsizeImageWithIndex:currentIndex];
	[self preloadThumbnailImages];
}


#pragma mark - FGalleryPhoto Delegate Methods


- (void)galleryPhoto:(FGalleryPhoto*)photo willLoadThumbnailFromPath:(NSString*)path
{
	// show activity indicator for large photo view
	FGalleryPhotoView *photoView = [photoViews objectAtIndex:photo.tag];
	[photoView.activity startAnimating];
	
	// show activity indicator for thumbail 
	if( isThumbViewShowing ) {
		FGalleryPhotoView *thumb = [photoThumbnailViews objectAtIndex:photo.tag];
		[thumb.activity startAnimating];
	}
}

- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadThumbnail:(UIImage*)image
{
	// grab the associated image view
	FGalleryPhotoView *photoView = [photoViews objectAtIndex:photo.tag];
	
	// if the gallery photo hasn't loaded the fullsize yet, set the thumbnail as its image.
	if( !photo.hasFullsizeLoaded )
		photoView.imageView.image = photo.thumbnail;

	[photoView.activity stopAnimating];
	
	// grab the thumbail view and set its image
	FGalleryPhotoView *thumbView = [photoThumbnailViews objectAtIndex:photo.tag];
	thumbView.imageView.image = image;
	[thumbView.activity stopAnimating];
}



- (void)galleryPhoto:(FGalleryPhoto*)photo didLoadFullsize:(UIImage*)image
{
	// only set the fullsize image if we're currently on that image
	if( currentIndex == photo.tag )
	{
		FGalleryPhotoView *photoView = [photoViews objectAtIndex:photo.tag];
		photoView.imageView.image = photo.fullsize;
	}
	// otherwise, we don't need to keep this image around
	else [photo unloadFullsize];
}


#pragma mark - UIScrollView Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	isScrolling = YES;
}
 

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if( !decelerate )
	{
		[self scrollingHasEnded];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self scrollingHasEnded];
}

@end


/**
 *	This section overrides the auto-rotate methods for UINaviationController and UITabBarController 
 *	to allow the tab bar to rotate only when a FGalleryController is the visible controller. Sweet.
 */
/*
@implementation UINavigationController (FGallery)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if([self.visibleViewController isKindOfClass:[GalleryViewController class]])
	{
        return YES;
	}

	// To preserve the UINavigationController's defined behavior,
	// walk its stack.  If all of the view controllers in the stack
	// agree they can rotate to the given orientation, then allow it.
	BOOL supported = YES;
	for(UIViewController *sub in self.viewControllers)
	{
		if(![sub shouldAutorotateToInterfaceOrientation:interfaceOrientation])
		{
			supported = NO;
			break;
		}
	}	
	if(supported)
		return YES;
	
	// we need to support at least one type of auto-rotation we'll get warnings.
	// so, we'll just support the basic portrait.
	return ( interfaceOrientation == UIInterfaceOrientationPortrait ) ? YES : NO;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// see if the current controller in the stack is a gallery
	if([self.visibleViewController isKindOfClass:[GalleryViewController class]])
	{
		GalleryViewController *galleryController = (GalleryViewController*)self.visibleViewController;
		[galleryController resetImageViewZoomLevels];
	}
}
@end

*/



