//
//  MLOverlayView 
//  MonaLisaMac
//
//  Created by brandon on 10/22/2013.
//  Copyright (c) 2013 Robots and Pencils Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MLOverlayView.h"

@implementation MLOverlayView

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (!(self = [super initWithCoder:aDecoder])) return nil;

    self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;

    return self;
}

#pragma mark - Private

- (CGRect)scaleRect:(CGRect)rect fromContainingSize:(CGSize)containingSize toContainingSize:(CGSize)targetSize {
    CGFloat widthScale = targetSize.width / containingSize.width;
    CGFloat heightScale = targetSize.height / containingSize.height;
    CGFloat scale = MIN(widthScale, heightScale);
    CGRect scaledRect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
    return scaledRect;
}

- (CGPoint)scalePoint:(CGPoint)point fromContainingSize:(CGSize)containingSize toContainingSize:(CGSize)targetSize {
    CGFloat widthScale = targetSize.width / containingSize.width;
    CGFloat heightScale = targetSize.height / containingSize.height;
    CGFloat scale = MIN(widthScale, heightScale);
    CGPoint scaledPoint = CGPointMake(point.x * scale, point.y * scale);
    return scaledPoint;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Iterate the detected faces
    for (CIFaceFeature *face in self.faces) {
        // Get the bounding rectangle of the face
        CGRect bounds = [self scaleRect:face.bounds fromContainingSize:self.capturedImageSize toContainingSize:self.bounds.size];

        [[NSColor redColor] set];
        NSBezierPath *faceRect = [NSBezierPath bezierPathWithRect:NSRectFromCGRect(bounds)];
        [faceRect stroke];

        // Get the position of facial features
        if (face.hasLeftEyePosition) {
            CGPoint leftEyePosition = [self scalePoint:face.leftEyePosition fromContainingSize:self.capturedImageSize toContainingSize:self.bounds.size];

            [[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
            [NSBezierPath strokeRect:NSMakeRect(leftEyePosition.x - 10.0, leftEyePosition.y - 10.0, 20.0, 20.0)];
        }

        if (face.hasRightEyePosition) {
            CGPoint rightEyePosition = [self scalePoint:face.rightEyePosition fromContainingSize:self.capturedImageSize toContainingSize:self.bounds.size];

            [[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
            [NSBezierPath strokeRect:NSMakeRect(rightEyePosition.x - 10.0, rightEyePosition.y - 10.0, 20.0, 20.0)];
        }

        if (face.hasMouthPosition) {
            CGPoint mouthPosition = [self scalePoint:face.mouthPosition fromContainingSize:self.capturedImageSize toContainingSize:self.bounds.size];

            [[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
            [NSBezierPath strokeRect:NSMakeRect(mouthPosition.x - 10.0, mouthPosition.y - 10.0, 20.0, 20.0)];
        }
    }
}

@end
