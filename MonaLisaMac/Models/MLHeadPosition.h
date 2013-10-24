//
//  MLHeadPosition.h
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//
//  Ported from https://github.com/auduno/headtrackr/blob/master/src/headposition.js
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/**
* Average head dimensions in cm
*/
extern const NSInteger MLAverageHeadWidth;
extern const NSInteger MLAverageHeadHeight;

@interface MLHeadPosition : NSObject

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;
@property (nonatomic, readonly) CGFloat z;

/**
*
* @param    x   x coordinate in cm
* @param    y   y coordinate in cm
* @param    z   z coordinate in cm
*
*/
- (id)initWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;

/**
*
* Calculates the position of a head in 3d space in cm relative to the center of the screen
*
* @param    face                A detected face
* @param    cameraFieldOfView   Camera FOV in degrees
* @param    cameraOffset        Camera offset from screen center in cm
* @param    imageSize           Size of the image used to detect the face
*
* @return   headPosition        The position of the head with x,y,z coordinates in cm
*
*/
+ (MLHeadPosition *)headPositionOfCIFaceFeature:(CIFaceFeature *)face cameraFieldOfView:(CGFloat)cameraFieldOfView cameraOffsetFromScreen:(CGSize)cameraOffset detectedImageSize:(CGSize)imageSize;

@end
