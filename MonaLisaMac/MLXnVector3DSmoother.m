//
//  MLXnVector3DSmoother.m
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLXnVector3DSmoother.h"

@interface MLXnVector3DSmoother ()

@property (nonatomic) XnVector3D smoothedPosition;
@property (nonatomic) XnVector3D smoothedPosition2;

@property (nonatomic) XnFloat alpha;
@property (nonatomic) NSTimeInterval interval;

@end

@implementation MLXnVector3DSmoother

- (id)initWithVector:(XnVector3D)vector interval:(NSTimeInterval)interval {
    if (!(self = [super init])) return nil;

    _smoothedPosition = vector;
    _smoothedPosition2 = _smoothedPosition;
    _alpha = 0.35;
    _interval = interval;

    return self;
}

- (XnVector3D)smooth:(XnVector3D)vector {
    XnVector3D smoothedPosition = self.smoothedPosition;
    smoothedPosition.X = self.alpha * vector.X + (1 - self.alpha) * smoothedPosition.X;
    smoothedPosition.Y = self.alpha * vector.Y + (1 - self.alpha) * smoothedPosition.Y;
    smoothedPosition.Z = self.alpha * vector.Z + (1 - self.alpha) * smoothedPosition.Z;
    self.smoothedPosition = smoothedPosition;

    XnVector3D smoothedPosition2 = self.smoothedPosition2;
    smoothedPosition2.X = self.alpha * smoothedPosition.X + (1 - self.alpha) * smoothedPosition2.X;
    smoothedPosition2.Y = self.alpha * smoothedPosition.Y + (1 - self.alpha) * smoothedPosition2.Y;
    smoothedPosition2.Z = self.alpha * smoothedPosition.Z + (1 - self.alpha) * smoothedPosition2.Z;
    self.smoothedPosition2 = smoothedPosition2;

    // set time
    NSTimeInterval updateTime = [[NSDate date] timeIntervalSince1970];

    NSTimeInterval msDiff = [[NSDate date] timeIntervalSince1970] - updateTime;
    XnVector3D newPosition = [self predict:msDiff];
    return newPosition;
}

- (XnVector3D)predict:(NSTimeInterval)time {
    XnFloat step = (XnFloat)(time / self.interval);
    XnFloat ratio = (self.alpha * step) / (1 - self.alpha);
    XnFloat a = 2 + ratio;
    XnFloat b = 1 + ratio;

    XnFloat x = a * self.smoothedPosition.X - b * self.smoothedPosition2.X;
    XnFloat y = a * self.smoothedPosition.Y - b * self.smoothedPosition2.Y;
    XnFloat z = a * self.smoothedPosition.Z - b * self.smoothedPosition2.Z;

    XnVector3D headPosition = {X: x, Y: y, Z: z};
    return headPosition;
}

@end
