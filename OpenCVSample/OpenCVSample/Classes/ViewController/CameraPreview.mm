//
//  CameraPreview.m
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 6/4/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import "CameraPreview.h"

@implementation CameraPreview

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession *)session
{
    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.previewLayer.session = session;
}

@end
