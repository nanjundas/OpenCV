//
//  CameraPreview.h
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 6/4/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraPreview : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic) AVCaptureSession *session;

@end

