//
//  ShapeDetector.h
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 27/3/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>

@interface Shape : NSObject

@end

@interface ShapeDetector : NSObject

+ (NSString *)getFormattedShapesForImage:(cv::Mat&)image;

@end
