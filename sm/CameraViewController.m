//
//  CameraViewController.m
//  sm
//
//  Created by Anthonio Ez on 7/4/15.
//  Copyright (c) 2015 Selfie Modelling. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraViewController.h"
#import <CoreGraphics/CoreGraphics.h>

#define CAPTURE_FRAMES_PER_SECOND		20

@interface CameraViewController ()
{
    AVCaptureSession *session;
    AVCaptureDevice *device;
    AVCaptureDeviceInput *deviceInput;

    AVCaptureStillImageOutput *imageOutput;
    AVCaptureMovieFileOutput *videoOutput;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    
    NSTimer *timer;

    NSURL *videoURL;
    
    BOOL running;
}
@end

@implementation CameraViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: [Utils makeXibName: nibNameOrNil] bundle:nibBundleOrNil];
    if (self)
    {
        self.count = COUNT_WAIT;
        self.total = 10;
        
        previewLayer = nil;
        timer = nil;
        running = false;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:ADMOB_INTERS_ID];
    self.interstitial.delegate = self;
    
    [self.interstitial loadRequest:[GADRequest request]];
    
    [self sessionStart];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraOrientationChanged)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Session
- (void) sessionStart
{
    [self counterStop];
    
    [self.statusLabel setText:@""];
    [self.countLabel setText:@""];
    
    if([self cameraStart])
    {
        [self counterStart];
    }
}

- (void) sessionStop
{
    running = false;
    [self counterStop];
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    
    [self cameraStop];
}

- (void) nextScreen
{
    FinalViewController *finalController = [[FinalViewController alloc] initWithNibName:@"FinalViewController" bundle:nil];
    finalController.videoUrl = videoURL;
    finalController.photo = self.photo;
    [[AppDelegate rootController] pushViewController:finalController animated:YES];

    if (self.interstitial.isReady)
    {
        [self.interstitial presentFromRootViewController:self];
    }
}

#pragma mark - IBActions
- (IBAction)onStop:(id)sender
{
    [self sessionStop];
   
    [self nextScreen];
    
}

#pragma mark - GADInterstitialDelegate
- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"interstitialDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial
{
}


#pragma mark - Camera
- (BOOL) cameraStart
{
    session = [AVCaptureSession new];
    
    //    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    device = [Utils selectCamera: [Settings getCameraFront] ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
    if(device == nil)
    {
        [Utils message:nil : @"Camera not found!"];
        return false;
    }
    
    if(![Settings getCameraFront])
    {
        if ([Settings getFlash])
        {
            if(self.photo)
            {
                if([device hasFlash])
                {
                    [device lockForConfiguration:nil];
                    [device setFlashMode:AVCaptureFlashModeOn];
                    [device unlockForConfiguration];
                }
            }
            else
            {
                if([device hasTorch])
                {
                    [device lockForConfiguration:nil];
                    [device setTorchMode:AVCaptureTorchModeOn];
                    [device unlockForConfiguration];
                }
            }
        }
    }
    
    NSError *error;
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if ( deviceInput != nil && [session canAddInput:deviceInput] )
    {
        [session addInput:deviceInput];
    }
    else
    {
        [Utils message:nil :@"Unable to add camera input"];
        return false;
    }
    
    if(!self.photo)
    {
        //ADD AUDIO INPUT
        NSLog(@"Adding audio input");
        AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
        if (audioInput)
        {
            [session addInput:audioInput];
        }
    }
    
    
    // Preview
    CALayer *viewLayer = [[self view] layer];
    [viewLayer setMasksToBounds:YES];
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CGRect layerRect = [viewLayer bounds];
    [previewLayer setBounds:layerRect];
    [previewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    

//    previewLayer.frame = self.view.bounds;
    
    [viewLayer insertSublayer:previewLayer atIndex:0];
    //[viewLayer addSublayer:previewLayer];
    
    
    if(self.photo)
    {
        [session setSessionPreset: AVCaptureSessionPresetPhoto];
        
        imageOutput = [[AVCaptureStillImageOutput alloc] init];
        //    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, 1.0, AVVideoQualityKey, nil];
        NSDictionary *outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG, AVVideoQualityKey:@1.0};
        
        [imageOutput setOutputSettings:outputSettings];
        if ([session canAddOutput:imageOutput])
            [session addOutput:imageOutput];
    }
    else
    {
        if ([session canSetSessionPreset:AVCaptureSessionPresetHigh])
            [session setSessionPreset:AVCaptureSessionPresetHigh];
        
        videoOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        Float64 TotalSeconds = self.total * 60;			//Total seconds
        int32_t preferredTimeScale = 30;	//Frames per second
        CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
        
        videoOutput.maxRecordedDuration = maxDuration;
        videoOutput.minFreeDiskSpaceLimit = 1024 * 1024;						//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
        
        if ([session canAddOutput:videoOutput])
            [session addOutput:videoOutput];
        
    }
    
    [session startRunning];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    return true;
}

- (void) cameraStop
{
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    
    if(self.photo)
    {
        
    }
    else
    {
        [videoOutput stopRecording];
    }
    
    [previewLayer removeFromSuperlayer];
    previewLayer = nil;
    
    if(![Settings getCameraFront])
    {
        if ([Settings getFlash])
        {
            if(self.photo)
            {
                if([device hasFlash])
                {
                    [device lockForConfiguration:nil];
                    [device setFlashMode:AVCaptureFlashModeOff];
                    [device unlockForConfiguration];
                }
            }
            else
            {
                if([device hasTorch])
                {
                    [device lockForConfiguration:nil];
                    [device setTorchMode:AVCaptureTorchModeOff];
                    [device unlockForConfiguration];
                }
            }
        }
    }
    
    [session stopRunning];
}

-(void) cameraOrientationChanged
{
    NSLog(@"orientation changed!");
    
    if(previewLayer == nil) return;
    
    //UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    //[previewLayer.connection setVideoOrientation: [Utils deviceToCaptureOrientation: deviceOrientation]];
}

#pragma mark - Timer
- (void) counterStart
{
    self.count = COUNT_WAIT;
    
    [self.countLabel setText: [NSString stringWithFormat:@"%d", self.count]];
    

    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow: 1];
    
    timer = [[NSTimer alloc] initWithFireDate:fireDate interval:1 target:self selector:@selector(countdownTimeout:) userInfo:nil repeats:YES];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer: timer forMode:NSDefaultRunLoopMode];
}

- (void) counterStop
{
    if(timer != nil)
    {
        [timer invalidate];
        timer = nil;
    }
}

- (void) countdownTimeout:(NSTimer*)theTimer
{
    if(running)
    {
        if(self.photo)
        {
        }
        else
        {
            self.count--;

            if(self.count < 0)
            {
                [self onStop:nil];

                return;
            }

            long interval = self.count;
            
            long seconds = interval % 60;
            interval /= 60;
            long minutes = interval % 60;

            
            [self.statusLabel setText: [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds]];
        }
    }
    else
    {
        self.count--;
        if(self.count <= 0)
        {
            running = true;
            [self.countLabel setText: @""];
            [self.statusLabel setText: @""];
            

            if(self.photo)
            {
                [self counterStop];
                
                self.count = 0;
                [self capturePhoto];
            }
            else
            {
                self.count = self.total * 60;
                [self captureVideo];
            }
        }
        else
        {
            [self.statusLabel setText: @""];
            [self.countLabel setText: [NSString stringWithFormat:@"%d", self.count]];
        }
    }
}

#pragma mark - Capture
- (void) captureVideo
{
    [self.countLabel setText: @""];
    
    if (!session || !session.isRunning)
    {
        [Utils message:nil : @"Camera session not available!"];
        return;
    }
    
    AVCaptureConnection *videoConnection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
    if(videoConnection == nil)
    {
        [Utils message:nil : @"Camera connection not available!"];
        return;
    }
    
    UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
    if ([videoConnection isVideoOrientationSupported])
    {
        if(deviceOrientation == UIDeviceOrientationLandscapeLeft)
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        else if(deviceOrientation == UIDeviceOrientationLandscapeRight)
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
        else if(deviceOrientation == UIDeviceOrientationPortrait)
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        else if(deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
        else
        {
//            [videoConnection setVideoOrientation:previewLayer.connection.videoOrientation];
        }

        
        // [videoConnection setVideoOrientation: [self getOrientation]];
    }
    
    //Set frame rate (if requried)
    CMTimeShow(device.activeVideoMinFrameDuration);
    CMTimeShow(device.activeVideoMaxFrameDuration);
    
    /*
    CMTimeShow(videoConnection.videoMinFrameDuration);
    CMTimeShow(videoConnection.videoMaxFrameDuration);
    
    if (videoConnection.supportsVideoMinFrameDuration)
        videoConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    
    if (videoConnection.supportsVideoMaxFrameDuration)
        videoConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
    
    CMTimeShow(videoConnection.videoMinFrameDuration);
    CMTimeShow(videoConnection.videoMaxFrameDuration);
     */
    
    NSString *file = [NSString stringWithFormat:@"video_%ld.mov", (long)[[NSDate date] timeIntervalSince1970]];
    NSString* path = [[AppDelegate path] stringByAppendingPathComponent: file ];
    [Utils deleteFile: path];

    NSLog(@"video path: file://%@", path);
    
    videoURL = [[NSURL alloc] initFileURLWithPath:path];
    
    //Start recording
    [videoOutput startRecordingToOutputFileURL:videoURL recordingDelegate:self];
}

- (void) capturePhoto
{
    if (!session || !session.isRunning)
    {
        [Utils message:nil :@"Camera session not available!"];
        return;
    }
    
    AVCaptureConnection *videoConnection = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if(videoConnection == nil)
    {
        [Utils message:nil : @"Camera connection not available!"];
        return;
    }

    UIDeviceOrientation currentDeviceOrientation = UIDevice.currentDevice.orientation;
    [imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             //NSLog(@"attachements: %@", exifAttachments);
         }
         else
         {
             //NSLog(@"no attachments");
         }
         
         if(imageSampleBuffer != nil)
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             
             if (imageData)
             {
                 UIImage *image = [[UIImage alloc] initWithData: imageData];
                 
                 NSLog(@"original device orient: %@", [Utils deviceOrientName: currentDeviceOrientation]);
                 NSLog(@"original image orient: %@", [Utils imageOrientName: image.imageOrientation]);
                 
                 //UIImageOrientation imageOrientation = [Utils deviceToImageOrientation: deviceOrientation image:image.imageOrientation];
                 
                 //NSLog(@"generated image orient: %@", [Utils imageOrientName: imageOrientation]);
                 
                 //image = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0f orientation: imageOrientation];
                 
                 //NSLog(@"filed image orient: %@", [Utils imageOrientName: image.imageOrientation]);
                 
                 //[self saveLocal: image];
                 
                 UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
             }
             else
             {
                 NSLog(@"unable to capture/save image");
             }
             
         }
         
         [self.statusLabel setText: [NSString stringWithFormat:@"%d/%d", self.count+1, self.total]];
         
         self.count++;
         NSLog(@"count: %d", self.count);
         
         if(self.count >= self.total)
         {
             [self sessionStop];
             
             [self nextScreen];
         }
         else
         {
             [self performSelector:@selector(capturePhoto) withObject:nil afterDelay:5];
         }
     }];
}

#pragma mark - Image processing
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == NULL)
    {
        NSLog(@"info: %@", contextInfo);

        [self saveLocal: image];
    }
}

- (void) saveLocal: (UIImage *)image
{
    if (image != nil)
    {
        NSString *file = [NSString stringWithFormat:@"photo_%ld.png", (long)[[NSDate date] timeIntervalSince1970]];
        NSString* path = [[AppDelegate path] stringByAppendingPathComponent: file ];
        [Utils deleteFile: path];

        NSData* data = UIImageJPEGRepresentation(image, 50);
        if([data writeToFile:path atomically:YES])
        {
            [[AppDelegate photos] addObject: path];
            
            NSLog(@"images added: %@", path);
        }
    }
}

#pragma mark - Video Processing
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"didFinishRecordingToOutputFileAtURL - enter");

    BOOL completed = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            completed = [value boolValue];
        }
    }

    if (completed)
    {
        //UISaveVideoAtPathToSavedPhotosAlbum(NSString *videoPath, id completionTarget, SEL completionSelector, void *contextInfo) NS_AVAILABLE_IOS(3_1);
                
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error)
            {
                if (error)
                {
                    videoURL = outputFileURL;
                }
            }];
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
}

@end
