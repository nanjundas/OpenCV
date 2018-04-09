//
//  ShapeDetector.m
//  OpenCVSample
//
//  Created by Nanjundaswamy Sainath on 27/3/18.
//  Copyright © 2018 Nanjundaswamy Sainath. All rights reserved.
//

#import <opencv2/opencv.hpp>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#import "ShapeDetector.h"

using namespace std;
using namespace cv;

@implementation Shape

@end


@implementation ShapeDetector


//(P1L1(x1, y1), P2L1(x2, y2) and P1L1(x1, y1), P2L3(x2, y3))
float angele(cv::Point P1L1, cv::Point P2L1, cv::Point P1L2, cv::Point P2L2)
{
    float dx21 = P2L1.x-P1L2.x;
    float dx31 = P2L2.x-P1L1.x;
    float dy21 = P2L1.y-P1L1.y;
    float dy31 = P2L2.y-P1L1.y;
    float m12 = sqrt( dx21*dx21 + dy21*dy21 );
    float m13 = sqrt( dx31*dx31 + dy31*dy31 );
    float theta = acos( (dx21*dx31 + dy21*dy31) / (m12 * m13) );
    
    return theta;
}

std::vector<int> findRects(cv::Mat &src)
{
    std::vector<int> retVal;
    cv::Mat src_gray;
    
    if (src.empty())
        return retVal;

    cvtColor( src, src_gray, CV_BGR2GRAY);
    
    cv::Mat bw;
    cv::Canny(src_gray, bw, 0, 50, 5);

    std::vector<std::vector<cv::Point> > contours;
    cv::findContours(bw.clone(), contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
    
    std::vector<cv::Point> approx;
    
    int tris = 0;
    int rects = 0;
    int circles = 0;
    
    for (int i = 0; i < contours.size(); i++){
        
        cv::approxPolyDP(cv::Mat(contours[i]), approx, cv::arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        if (std::fabs(cv::contourArea(contours[i])) < 100 || !cv::isContourConvex(approx))
            continue;
        
        if (approx.size() == 3){
            
            int vtc = (int)approx.size();

            std::vector<float> angles;
            
            angles.push_back(angele(approx[0], approx[1], approx[0], approx[2]));
            angles.push_back(angele(approx[0], approx[1], approx[1], approx[2]));
            angles.push_back(angele(approx[1], approx[2], approx[2], approx[1]));
            
            std::sort(angles.begin(), angles.end());
            
            for (int j = 0; j < vtc; j++) {
                printf("%f ", angles[j]);
            }
                
            printf("\n");
            
            tris++;
        }
        else if (approx.size() == 4){
            rects++;
        }
        else{
            
            double area = cv::contourArea(contours[i]);
            cv::Rect r = cv::boundingRect(contours[i]);
            int radius = r.width / 2;
            
            if (std::abs(1 - ((double)r.width / r.height)) <= 0.2 &&
                std::abs(1 - (area / (CV_PI * std::pow(radius, 2)))) <= 0.2)
                circles++;
        }
    }
    
    retVal.push_back(tris);
    retVal.push_back(rects);
    retVal.push_back(circles);
    
    return retVal;
}

+ (NSString *)getFormattedShapesForImage:(cv::Mat&)image
{
    if (image.empty())
        return @"";
    
    NSMutableString *retString = [NSMutableString string];
    std::vector<int> ret = findRects(image);
    
    if (ret.size() > 0) {
        [retString appendFormat:@"Triangles - %d Rectangles - %d Circles - %d", ret[0], ret[1], ret[2]];
    }
    
    return retString;
}

@end
