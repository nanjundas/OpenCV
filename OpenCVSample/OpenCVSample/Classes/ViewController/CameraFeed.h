//
//  CameraFeed.h
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 1/4/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//TODO - Make this a common class to switch between OpenCV Camera and CameraFeed Camera

@protocol CameraFeed<NSObject>

- (void)setupCamera;

- (void)start;
- (void)stop;

- (void)setQuality:(NSString *)quality;

@end

@interface CameraFeed : NSObject<CameraFeed>

@property(nonatomic, retain, readonly) AVCaptureSession *session;

@end
