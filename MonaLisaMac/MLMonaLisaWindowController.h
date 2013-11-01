//
//  MLMonaLisaWindowController.h
//  MonaLisaMac
//
//  Created by Brandon on 10/24/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "XnTypes.h"

@interface MLMonaLisaWindowController : NSWindowController

- (void)updateEyeLocationWithHeadPosition:(XnVector3D)headPosition;
- (void)randomImageFlicker;

@end
