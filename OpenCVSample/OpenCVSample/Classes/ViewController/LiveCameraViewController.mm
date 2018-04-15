//
//  LiveCameraViewController.m
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 26/3/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;}

#import "ShapeDetector.h"

// CvVideoCamera - Needs Apple frameworks(CoreImage/CoreMedia/CoreVideo/AVFoundation....) to be included. Refer documentation.

#import "LiveCameraViewController.h"
#import "CameraFeed.h"
#import "CameraPreview.h"

@interface LiveCameraViewController ()<CvVideoCameraDelegate, CameraFeedDelegate>

@property (nonatomic, retain) IBOutlet CameraPreview *feedImageView;
@property (nonatomic, retain) IBOutlet UILabel *outputLabel;

@property (nonatomic, assign) BOOL feedRunning;

// Add UI options to switch camera;
@property (nonatomic, retain) CvVideoCamera *camera;
@property (nonatomic, retain) CameraFeed *customCamera;

- (IBAction)onBarbuttonClicked:(id)sender;

@end

@implementation LiveCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.outputLabel.layer.cornerRadius = 5;
    self.outputLabel.clipsToBounds = YES;
    
    //TODO: Give an option in UI.
    //Change this to switch between cameras.
    BOOL useCVCamera = NO;
    if (useCVCamera) {
        
        // Creating CvVideoCamera Object to capture live video
        CvVideoCamera *camera = [[CvVideoCamera alloc] initWithParentView:self.feedImageView];
        camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
        camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        camera.rotateVideo = YES; // Handles orientation
        camera.delegate = self;
        
        self.camera = camera;
    }
    else {
        
        CameraFeed *customCamera = [[CameraFeed alloc] init];
        customCamera.previewView = self.feedImageView;
        
        customCamera.previewView.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        customCamera.delegate = self;
        [customCamera setupCamera];
        
        self.customCamera = customCamera;
    }

#if !(TARGET_IPHONE_SIMULATOR)
    
    // Pause/Resume Recording when app enters BG/FG
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBG:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterFG:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
#endif
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if (self.customCamera != nil){
       // self.customCamera.previewView.previewLayer.frame = self.feedImageView.bounds;
    }
}

- (void)dealloc {
    
#if !(TARGET_IPHONE_SIMULATOR)
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
#endif
}

- (void)toggleFeed {
    
    self.feedRunning ? [self.camera stop] : [self.camera start];
    self.feedRunning ? [self.customCamera stop] : [self.customCamera start];
    
    self.feedRunning = !self.feedRunning;
}

- (void)didEnterBG:(id)notification {
    
    if (self.feedRunning) {
        [self.camera stop];
        [self.customCamera stop];
    }
}

- (void)didEnterFG:(id)notification {
    
    if (self.feedRunning) {
        [self.camera start];
        [self.customCamera start];
    }
}

#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image {
    
    return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        __block NSString *ret = [ShapeDetector getFormattedShapesForImage:image];
        if ([ret length]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.outputLabel.text = ret;
            });
        }
    });
}

#pragma mark - CameraFeedDelegate

- (void)didOutputImage:(cv::Mat&)image {
    
    try {
        __block NSString *ret = [ShapeDetector getFormattedShapesForImage:image];
        if ([ret length]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.outputLabel.text = ret;
            });
        }
    } catch (id exception) {
        NSLog(@"exception - %@", exception);
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    int angle = 0;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation)
    {
        case UIDeviceOrientationPortrait: angle = 0; break;
        case UIDeviceOrientationPortraitUpsideDown:  angle = 180; break;
        case UIDeviceOrientationLandscapeLeft:  angle = 270; break;
        case UIDeviceOrientationLandscapeRight:  angle = 90; break;
        default:
            break;
    }

    self.customCamera.previewView.previewLayer.affineTransform = CGAffineTransformIdentity;
    self.customCamera.previewView.previewLayer.affineTransform = CGAffineTransformMakeRotation(DegreesToRadians(angle));
}

#pragma mark - IBAction

- (IBAction)onSegmentValueChanged:(UISegmentedControl*)sender {
    self.camera.defaultAVCaptureSessionPreset = sender.selectedSegmentIndex == 0 ? AVCaptureSessionPresetHigh : AVCaptureSessionPresetLow;
}

- (IBAction)onBarbuttonClicked:(UIBarButtonItem*)sender {

#if !(TARGET_IPHONE_SIMULATOR)
    [self toggleFeed];
#endif
    
    [sender setTitle:self.feedRunning ? @"Stop" : @"Start"];
}

@end
