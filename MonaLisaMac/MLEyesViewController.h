//
//  MLEyesViewController.h
//  MonaLisaMac
//
//  Created by Brandon on 10/24/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MLEyesViewController : NSViewController

- (void)setLeftEyeTransform:(CATransform3D)transform;
- (void)setRightEyeTransform:(CATransform3D)transform;

@end
