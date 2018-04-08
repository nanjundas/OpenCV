//
//  CameraFeed.h
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 1/4/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "CameraPreview.h"

//TODO - Make this a common class to switch between OpenCV Camera and CameraFeed Camera

@protocol CameraFeed<NSObject>

- (void)setupCamera;

- (void)start;
- (void)stop;

// TODO - Add more options;
- (void)setQuality:(AVCaptureSessionPreset)quality;

@end

@protocol CameraFeedDelegate<NSObject>

- (void)didOutputImage:(cv::Mat&)image;
    
@end

@interface CameraFeed : NSObject<CameraFeed>

@property(nonatomic, weak) id<CameraFeedDelegate> delegate;

@property(nonatomic, retain, readonly) AVCaptureSession *session;

@property(nonatomic, retain) CameraPreview *previewView;

@end
