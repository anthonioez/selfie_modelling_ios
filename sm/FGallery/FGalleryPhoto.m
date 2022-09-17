//
//  FGalleryPhoto.m
//  FGallery
//
//  Created by Grant Davis on 5/20/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "Utils.h"
#import "FGalleryPhoto.h"

@interface FGalleryPhoto (Private)

// delegate notifying methods

@end


@implementation FGalleryPhoto
@synthesize tag;
@synthesize thumbnail = _thumbnail;
@synthesize fullsize = _fullsize;
@synthesize delegate = _delegate;
@synthesize isFullsizeLoading = _isFullsizeLoading;
@synthesize hasFullsizeLoaded = _hasFullsizeLoaded;
@synthesize isThumbLoading = _isThumbLoading;
@synthesize hasThumbLoaded = _hasThumbLoaded;


- (id)initWithThumbnailUrl:(NSString*)thumb fullsizeUrl:(NSString*)fullsize delegate:(NSObject<FGalleryPhotoDelegate>*)delegate
{
	self = [super init];
	_thumbUrl = thumb ;
	_fullsizeUrl = fullsize ;
	_delegate = delegate;
	return self;
}

- (id)initWithThumbnailPath:(NSString*)thumb fullsizePath:(NSString*)fullsize delegate:(NSObject<FGalleryPhotoDelegate>*)delegate
{
	self = [super init];
	
	_thumbUrl = thumb;
	_fullsizeUrl = fullsize;
	_delegate = delegate;
	return self;
}


- (void)loadThumbnail
{
	if( _isThumbLoading || _hasThumbLoaded ) return;
	
    // notify delegate
    [self willLoadThumbFromPath];
    
    _isThumbLoading = YES;
    
    // spawn a new thread to load from disk
    [NSThread detachNewThreadSelector:@selector(loadThumbnailInThread) toTarget:self withObject:nil];
}


- (void)loadFullsize
{
	if( _isFullsizeLoading || _hasFullsizeLoaded ) return;
	
    [self willLoadFullsizeFromPath];
    
    _isFullsizeLoading = YES;
    
    // spawn a new thread to load from disk
    [NSThread detachNewThreadSelector:@selector(loadFullsizeInThread) toTarget:self withObject:nil];
}


- (void)loadFullsizeInThread
{
	NSString *path;
        
    if([[NSFileManager defaultManager] fileExistsAtPath:_fullsizeUrl])
    {
        path = _fullsizeUrl;
    }
    else {
        path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], _fullsizeUrl];
    }
			
	_fullsize = [UIImage imageWithContentsOfFile:path] ;
    if(_fullsize != nil) // && _fullsize.imageOrientation == UIImageOrientationRight)
    {
        NSLog(@"full orient: %@", [Utils imageOrientName: _fullsize.imageOrientation] );
        
        _fullsize = [[UIImage alloc] initWithCGImage:_fullsize.CGImage scale:1.0f orientation: UIImageOrientationRight];
    }
    
	_hasFullsizeLoaded = YES;
	_isFullsizeLoading = NO;

	[self performSelectorOnMainThread:@selector(didLoadFullsize) withObject:nil waitUntilDone:YES];
}


- (void)loadThumbnailInThread
{
	NSString *path;
        
    if([[NSFileManager defaultManager] fileExistsAtPath:_thumbUrl])
    {
        path = _thumbUrl;
    }
    else {
        path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], _thumbUrl];
    }
    
	_thumbnail = [UIImage imageWithContentsOfFile:path];
    if(_thumbnail != nil)   //&& _thumbnail.imageOrientation == UIImageOrientationRight)
    {
        _thumbnail = [[UIImage alloc] initWithCGImage:_thumbnail.CGImage scale:1.0f orientation: UIImageOrientationRight];
    }

	_hasThumbLoaded = YES;
	_isThumbLoading = NO;
	
	[self performSelectorOnMainThread:@selector(didLoadThumbnail) withObject:nil waitUntilDone:YES];
}


- (void)unloadFullsize
{
//	[self killFullsizeLoadObjects];
	
	_isFullsizeLoading = NO;
	_hasFullsizeLoaded = NO;
	
	_fullsize = nil;
}

- (void)unloadThumbnail
{
//	[self killThumbnailLoadObjects];
	
	_isThumbLoading = NO;
	_hasThumbLoaded = NO;
	
	_thumbnail = nil;
}


#pragma mark -
#pragma mark Delegate Notification Methods
- (void)willLoadThumbFromUrl
{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadThumbnailFromUrl:)])
		[_delegate galleryPhoto:self willLoadThumbnailFromUrl:_thumbUrl];
}


- (void)willLoadFullsizeFromUrl
{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadFullsizeFromUrl:)])
		[_delegate galleryPhoto:self willLoadFullsizeFromUrl:_fullsizeUrl];
}


- (void)willLoadThumbFromPath
{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadThumbnailFromPath:)])
		[_delegate galleryPhoto:self willLoadThumbnailFromPath:_thumbUrl];
}


- (void)willLoadFullsizeFromPath
{
	if([_delegate respondsToSelector:@selector(galleryPhoto:willLoadFullsizeFromPath:)])
		[_delegate galleryPhoto:self willLoadFullsizeFromPath:_fullsizeUrl];
}


- (void)didLoadThumbnail
{
//	FLog(@"gallery phooto did load thumbnail!");
	if([_delegate respondsToSelector:@selector(galleryPhoto:didLoadThumbnail:)])
		[_delegate galleryPhoto:self didLoadThumbnail:_thumbnail];
}


- (void)didLoadFullsize
{
//	FLog(@"gallery phooto did load fullsize!");
	if([_delegate respondsToSelector:@selector(galleryPhoto:didLoadFullsize:)])
		[_delegate galleryPhoto:self didLoadFullsize:_fullsize];
}


#pragma mark -
#pragma mark Memory Management
- (void)dealloc
{
//	NSLog(@"FGalleryPhoto dealloc");
	
//	[_delegate release];
	_delegate = nil;
	
	_thumbUrl = nil;
	
	_fullsizeUrl = nil;
	
	_thumbnail = nil;
	
	_fullsize = nil;
}


@end
