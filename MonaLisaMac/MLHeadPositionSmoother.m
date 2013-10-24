//
//  MLHeadPositionSmoother.m
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLHeadPositionSmoother.h"
#import "MLHeadPosition.h"

@interface MLHeadPositionSmoother ()

@property (strong, nonatomic) MLHeadPosition *smoothedPosition;
@property (strong, nonatomic) MLHeadPosition *smoothedPosition2;

@property (nonatomic) CGFloat alpha;
@property (nonatomic) NSTimeInterval interval;

@end

@implementation MLHeadPositionSmoother

- (id)initWithHeadPosition:(MLHeadPosition *)headPosition interval:(NSTimeInterval)interval {
    if (!(self = [super init])) return nil;

    _smoothedPosition = headPosition;
    _smoothedPosition2 = _smoothedPosition;
    _alpha = 0.35;
    _interval = interval;

    return self;
}

- (MLHeadPosition *)smooth:(MLHeadPosition *)headPosition {
    CGFloat x = self.alpha * headPosition.x + (1 - self.alpha) * self.smoothedPosition.x;
    CGFloat y = self.alpha * headPosition.y + (1 - self.alpha) * self.smoothedPosition.y;
    CGFloat z = self.alpha * headPosition.z + (1 - self.alpha) * self.smoothedPosition.z;
    self.smoothedPosition = [[MLHeadPosition alloc] initWithX:x y:y z:z];

    x = self.alpha * self.smoothedPosition.x + (1 - self.alpha) * self.smoothedPosition2.x;
    y = self.alpha * self.smoothedPosition.y + (1 - self.alpha) * self.smoothedPosition2.y;
    z = self.alpha * self.smoothedPosition.z + (1 - self.alpha) * self.smoothedPosition2.z;
    self.smoothedPosition2 = [[MLHeadPosition alloc] initWithX:x y:y z:z];

    // set time
    NSTimeInterval updateTime = [[NSDate date] timeIntervalSince1970];

    NSTimeInterval msDiff = [[NSDate date] timeIntervalSince1970] - updateTime;
    MLHeadPosition *newPosition = [self predict:msDiff];
    return newPosition;
}

- (MLHeadPosition *)predict:(NSTimeInterval)time {
    CGFloat step = time / self.interval;
    CGFloat ratio = (self.alpha * step) / (1 - self.alpha);
    CGFloat a = 2 + ratio;
    CGFloat b = 1 + ratio;

    CGFloat x = a * self.smoothedPosition.x - b * self.smoothedPosition2.x;
    CGFloat y = a * self.smoothedPosition.y - b * self.smoothedPosition2.y;
    CGFloat z = a * self.smoothedPosition.z - b * self.smoothedPosition2.z;

    MLHeadPosition *headPosition = [[MLHeadPosition alloc] initWithX:x y:y z:z];
    return headPosition;
}

@end
