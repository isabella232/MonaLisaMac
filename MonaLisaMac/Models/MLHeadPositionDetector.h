//
//  MLHeadPositionDetector.h
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

@class CIDetector;
@class AVCaptureSession;
@class MLHeadPositionSmoother;
@class MLHeadPosition;

@interface MLHeadPositionDetector : NSObject

@property (strong, nonatomic) AVCaptureSession *session;
@property (copy, nonatomic) void (^foundFacesBlock)(NSArray *, NSSize);
@property (copy, nonatomic) void (^foundPrimaryHeadPositionBlock)(MLHeadPosition *);

@end
