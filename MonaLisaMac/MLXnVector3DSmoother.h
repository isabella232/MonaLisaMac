//
//  MLXnVector3DSmoother.h
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//
//  Ported from https://github.com/auduno/headtrackr/blob/master/src/smoother.js
//

#import <Foundation/Foundation.h>
#include "XnTypes.h"

@interface MLXnVector3DSmoother : NSObject

/**
 *
 * Create a new smoothing object from a starting vector
 *
 * @param    vector    the initial vector
 * @param    interval        the time interval for face recognition
 *
 * @return   smoother        a new smoother
 *
 */
- (id)initWithVector:(XnVector3D)vector interval:(NSTimeInterval)interval;

/**
 *
 * Smooth movement based on a new vector
 *
 * @param    vector            the new vector
 *
 * @return    smoothedHeadPosition    the smoothed vector
 *
 */
- (XnVector3D)smooth:(XnVector3D)vector;

@end
