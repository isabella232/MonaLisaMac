//
//  MLHeadPositionSmoother.h
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//
//  Ported from https://github.com/auduno/headtrackr/blob/master/src/smoother.js
//

#import <Foundation/Foundation.h>

@class MLHeadPosition;

@interface MLHeadPositionSmoother : NSObject

/**
*
* Create a new smoothing object from a starting head position
*
* @param    headPosition    the initial head position
* @param    interval        the time interval for face recognition
*
* @return   smoother        a new smoother
*
*/
- (id)initWithHeadPosition:(MLHeadPosition *)headPosition interval:(NSTimeInterval)interval;

/**
*
* Smooth movement based on a new head position
*
* @param    headPosition            the new head position
*
* @return    smoothedHeadPosition    the smoothed head position
*
*/
- (MLHeadPosition *)smooth:(MLHeadPosition *)headPosition;

@end
