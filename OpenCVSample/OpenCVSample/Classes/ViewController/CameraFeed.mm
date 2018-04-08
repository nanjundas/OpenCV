//
//  CameraFeed.m
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 1/4/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <opencv2/imgcodecs/ios.h>

#import "CameraFeed.h"

@interface CameraFeed()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic) dispatch_queue_t sessionQueue;

@property (nonatomic) BOOL sessionConfigured;
@property (nonatomic) BOOL feedRunning;

@property (nonatomic) UIDeviceOrientation currentOrientation;

@property(nonatomic, retain, readwrite) AVCaptureSession *session;

@property (nonatomic, retain) AVCaptureDeviceInput *videoDeviceInput;

@end

@implementation CameraFeed

- (void)createSession {
 
    self.sessionQueue = dispatch_queue_create( "SessionQueue", DISPATCH_QUEUE_SERIAL );
    
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
    
    self.sessionConfigured = YES;
    
    //TODO - Add logic for check Camera Auth Status

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // Pause/Resume Recording when app enters BG/FG
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBG:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterFG:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    // Add Capture Output to read the image data
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init] ;
    [captureOutput setSampleBufferDelegate:self queue:self.sessionQueue];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    captureOutput.sampleBufferDelegate = self;
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    
#endif
    
}

- (void)dealloc {
    
#if !(TARGET_IPHONE_SIMULATOR)
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
#endif
}

- (void)deviceOrientationDidChange:(NSNotification*)notification {
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation)
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            self.currentOrientation = orientation;
            break;
        default:
            break;
    }

}


- (void)didEnterBG:(id)notification {
    
    if (self.feedRunning) {
        [self stop];
    }
}

- (void)didEnterFG:(id)notification {
    
    if (self.feedRunning) {
        [self start];
    }
}

- (void)start
{
    self.previewView.session = self.session;
    
    if (!self.sessionConfigured){
        [self setupCamera];
    }
    
    self.feedRunning = YES;
    [self.session startRunning];
}

- (void)stop
{
    self.feedRunning = NO;
    [self.session stopRunning];
}

- (void)setQuality:(AVCaptureSessionPreset)quality
{
    self.session.sessionPreset = quality;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    @autoreleasepool {
        
        CVImageBufferRef imageBuffer;
        CGImageRef newImage;
        size_t bytesPerRow;
        size_t width;
        size_t height;
        CGColorSpaceRef colorSpace;
        uint8_t *baseAddress;
        imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        
        bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        width = CVPixelBufferGetWidth(imageBuffer);
        height = CVPixelBufferGetHeight(imageBuffer);
        
        baseAddress = (uint8_t*)malloc( bytesPerRow * height );
        memcpy( baseAddress, CVPixelBufferGetBaseAddress(imageBuffer), bytesPerRow * height );
        colorSpace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
        newImage = CGBitmapContextCreateImage(context);
        
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        // TODO: Haandle Interface;
        
        UIImageOrientation imageOrientation;
        switch (self.currentOrientation) {
            case UIInterfaceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationUp;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationDown;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationLeft;
                break;
            default:
                imageOrientation = UIImageOrientationUp;
                break;
        }
        
        UIImage *cameraImage = nil;
        cameraImage= [UIImage imageWithCGImage:newImage scale:1 orientation:imageOrientation];
        
        cv::Mat matImage;
        UIImageToMat(cameraImage, matImage);
        
        if ([self.delegate respondsToSelector:@selector(didOutputImage:)]) {
            [self.delegate didOutputImage:matImage];
        }
        
        CGImageRelease(newImage);
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    }

}

@end
