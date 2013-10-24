//
//  MLHeadPosition.m
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLHeadPosition.h"

const NSInteger MLAverageHeadWidth = 16;
const NSInteger MLAverageHeadHeight = 19;

@implementation MLHeadPosition

- (id)initWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z {
    if (!(self = [super init])) return nil;

    _x = x;
    _y = y;
    _z = z;

    return self;
}

+ (MLHeadPosition *)headPositionOfCIFaceFeature:(CIFaceFeature *)face cameraFieldOfView:(CGFloat)cameraFieldOfView cameraOffsetFromScreen:(CGSize)cameraOffset detectedImageSize:(CGSize)imageSize {
    CGFloat faceWidth = face.bounds.size.width;
    CGFloat faceHeight = face.bounds.size.height;
    CGFloat faceX = face.bounds.origin.x;
    CGFloat faceY = face.bounds.origin.y;

    // Pre-calculate
    CGFloat headSmallAngle = atan(MLAverageHeadWidth / MLAverageHeadHeight);
    CGFloat faceDiagonalLengthCM = sqrt(MLAverageHeadWidth * MLAverageHeadWidth + MLAverageHeadHeight * MLAverageHeadHeight);
    CGFloat faceDiagonalLengthPX = sqrt(faceWidth * faceWidth + faceHeight * faceHeight);

    // Horizontal FOV of camera
    CGFloat cameraFOVInRadians = cameraFieldOfView * M_PI / 180.0f;

    // Ratio of face width / 2 and distance of face to camera
    CGFloat tanFOVWidth = 2.0f * tan(cameraFOVInRadians / 2.0f);

    CGFloat z = (faceDiagonalLengthCM * imageSize.width) / (tanFOVWidth * faceDiagonalLengthPX);
    CGFloat x = -((faceX / imageSize.width) - 0.5) * z * tanFOVWidth;
    CGFloat y = -((faceY / imageSize.height) - 0.5) * z * tanFOVWidth * (imageSize.height / imageSize.width);

    if (!CGSizeEqualToSize(cameraOffset, CGSizeZero)) {
        y -= cameraOffset.height;
        x -= cameraOffset.width;
    }

    MLHeadPosition *headPosition = [[MLHeadPosition alloc] initWithX:x y:y z:z];
    return headPosition;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@>: ", NSStringFromClass([self class])];
    [description appendString:[NSString stringWithFormat:@"%fcm, %fcm, %fcm", self.x, self.y, self.z]];
    return description;
}

@end
