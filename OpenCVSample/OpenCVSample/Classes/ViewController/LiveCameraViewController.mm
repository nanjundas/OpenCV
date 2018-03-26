//
//  LiveCameraViewController.m
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 26/3/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

// CvVideoCamera - Needs Apple frameworks(CoreImage/CoreMedia/CoreVideo/AVFoundation....) to be included. Refer documentation.

#import "LiveCameraViewController.h"

@interface LiveCameraViewController ()<CvVideoCameraDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *feedImageView;

@property (nonatomic, assign) BOOL feedRunning;
@property (nonatomic, retain) CvVideoCamera *camera;

- (IBAction)onBarbuttonClicked:(id)sender;

@end

@implementation LiveCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Creating CvVideoCamera Object to capture live video
    CvVideoCamera *camera = [[CvVideoCamera alloc] initWithParentView:self.feedImageView];
    camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    camera.rotateVideo = YES; // Handles orientation
    camera.delegate = self;
    
    self.camera = camera;

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
    
    NSLog(@"got new image");
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