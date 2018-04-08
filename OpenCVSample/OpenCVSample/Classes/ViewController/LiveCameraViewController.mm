//
//  LiveCameraViewController.m
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 26/3/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

#import "ShapeDetector.h"

// CvVideoCamera - Needs Apple frameworks(CoreImage/CoreMedia/CoreVideo/AVFoundation....) to be included. Refer documentation.

#import "LiveCameraViewController.h"
#import "CameraFeed.h"
#import "CameraPreview.h"

@interface LiveCameraViewController ()<CvVideoCameraDelegate>

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
    
    // Creating CvVideoCamera Object to capture live video
    CvVideoCamera *camera = [[CvVideoCamera alloc] initWithParentView:self.feedImageView];
    camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    camera.rotateVideo = YES; // Handles orientation
    camera.delegate = self;
    
    self.camera = camera;

    CameraFeed *customCamera = [[CameraFeed alloc] init];
    customCamera.previewView = self.feedImageView;
    [customCamera setupCamera];
    
    self.customCamera = customCamera;

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
    
    self.feedRunning = !self.feedRunning;
}

- (void)didEnterBG:(id)notification {
    
    if (self.feedRunning) {
        [self.camera stop];
    }
}

- (void)didEnterFG:(id)notification {
    
    if (self.feedRunning) {
        [self.camera start];
    }
}

#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat&)image {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        __block NSString *ret = [ShapeDetector getFormattedShapesForImage:image];
        if ([ret length]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.outputLabel.text = ret;
            });
        }
    });
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
