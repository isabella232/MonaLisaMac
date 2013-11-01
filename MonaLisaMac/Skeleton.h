//
//  Skeleton.h
//  CocoaOpenNI
//
//  Created by John Boiles on 2/9/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "XnCppWrapper.h"

@interface Skeleton : NSObject

@property (nonatomic) xn::UserGenerator userGenerator;
@property (nonatomic) XnUserID userID;

@property (nonatomic) XnSkeletonJointPosition head;
@property (nonatomic) XnSkeletonJointPosition neck;
@property (nonatomic) XnSkeletonJointPosition torso;

@property (nonatomic) XnSkeletonJointPosition leftShoulder;
@property (nonatomic) XnSkeletonJointPosition leftElbow;
@property (nonatomic) XnSkeletonJointPosition leftHand;

@property (nonatomic) XnSkeletonJointPosition rightShoulder;
@property (nonatomic) XnSkeletonJointPosition rightElbow;
@property (nonatomic) XnSkeletonJointPosition rightHand;

+ (Skeleton *)skeletonFromUserGenerator:(xn::UserGenerator)userGenerator user:(XnUserID)user;

- (BOOL)armsAreStraightOutToTheSide;

@end

XnSkeletonJointPosition GetJointPosition(xn::UserGenerator userGenerator, XnUserID user, XnSkeletonJoint joint);
