//
//  CameraFeed.m
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 1/4/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import "CameraFeed.h"

@interface CameraFeed()

@property(nonatomic, retain, readwrite) AVCaptureSession *session;

@property (nonatomic, retain) AVCaptureDeviceInput *videoDeviceInput;

@end

@implementation CameraFeed

- (void)createSession {
 
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.session = session;
}

- (void)setupCamera
{
#if !(TARGET_IPHONE_SIMULATOR)
 
    if (!self.session){
        self.session = [[AVCaptureSession alloc] init];
    }
    
    [self.session beginConfiguration];
    
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;

    // Back dual Camera
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    if ( ! videoDevice ) {

        // Back
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];

        // Front
        if ( ! videoDevice ) {
            videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if ( videoDeviceInput ) {
        
        if ( [self.session canAddInput:videoDeviceInput] ) {
            
            [self.session addInput:videoDeviceInput];
            
            self.videoDeviceInput = videoDeviceInput;
        }
        else {
            NSLog( @"Camera Setup failed: %@", error );
        }
    }
    else {
        NSLog( @"Camera Setup failed: %@", error );
    }
    
    [self.session commitConfiguration];

#endif
    
}

- (void)start
{
    
}

- (void)stop
{
    
}

- (void)setQuality:(NSString *)quality
{
    
}

@end
