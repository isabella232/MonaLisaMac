//
//  MLMonaLisaWindowController.m
//  MonaLisaMac
//
//  Created by Brandon on 10/24/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLMonaLisaWindowController.h"
#import "MLEyesViewController.h"

static CGFloat M_PI_6 = M_PI / 6.0;

@interface MLMonaLisaWindowController ()

@property (strong, nonatomic) IBOutlet NSImageView *monaLisaImageView;
@property (strong, nonatomic) MLEyesViewController *eyesViewController;

@end

@implementation MLMonaLisaWindowController

- (void)windowDidLoad {
    self.eyesViewController = [[MLEyesViewController alloc] initWithNibName:@"MLEyesView" bundle:nil];
    self.eyesViewController.view.frame = CGRectMake(350, 520, 250, 150);
    [self.window.contentView addSubview:self.eyesViewController.view positioned:NSWindowBelow relativeTo:self.monaLisaImageView];

    ((NSView *)self.window.contentView).layer.backgroundColor = [NSColor blackColor].CGColor;

    [self resizeMonaLisaForWindowSize:self.window.frame.size];
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
    NSWindow *window = notification.object;
    [self resizeMonaLisaForWindowSize:window.frame.size];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)windowSize {
    [self resizeMonaLisaForWindowSize:windowSize];
    return windowSize;
}

- (void)resizeMonaLisaForWindowSize:(NSSize)windowSize {
    CGFloat width = fmin(windowSize.width, self.monaLisaImageView.frame.size.width);
    CGFloat height = fmin(windowSize.height, self.monaLisaImageView.frame.size.width);
    CGFloat x = (windowSize.width - width) / 2;
    CGFloat y = (windowSize.height - height) / 2;

    self.monaLisaImageView.frame = CGRectMake(x, y, width, height);
}

- (void)updateEyeLocationWithHeadPosition:(XnVector3D)headPosition {
    CGFloat monaLisaEyeSeparationInMM = 40.0f;

    //Calculate angle from eye to face based on face position
    CGFloat leftHorizontalAngleInRadians = atan((monaLisaEyeSeparationInMM / 2 + headPosition.X) / headPosition.Z);
    CGFloat leftVerticalAngleInRadians = -atan(headPosition.Y / headPosition.Z);
    CGFloat rightHorizontalAngleInRadians = -atan((monaLisaEyeSeparationInMM / 2 - headPosition.X) / headPosition.Z);
    CGFloat rightVerticalAngleInRadians = -atan(headPosition.Y / headPosition.Z);

    // Horizontal movement of human eye is ~90deg
    // Vertical movement of human eye is ~60deg
    leftHorizontalAngleInRadians = fmax(-M_PI_4, fmin(leftHorizontalAngleInRadians, M_PI_4));
    leftVerticalAngleInRadians = fmax(-M_PI_6, fmin(leftVerticalAngleInRadians, M_PI_6));
    rightHorizontalAngleInRadians = fmax(-M_PI_4, fmin(rightHorizontalAngleInRadians, M_PI_2));
    rightVerticalAngleInRadians = fmax(-M_PI_6, fmin(rightVerticalAngleInRadians, M_PI_6));

    CATransform3D leftEyeTransform = CATransform3DMakeRotation(leftHorizontalAngleInRadians, 0.0, 1.0, 0.0);
    leftEyeTransform = CATransform3DRotate(leftEyeTransform, leftVerticalAngleInRadians, 1.0, 0.0, 0.0);

    CATransform3D rightEyeTransform = CATransform3DMakeRotation(rightHorizontalAngleInRadians, 0.0, 1.0, 0.0);
    rightEyeTransform = CATransform3DRotate(rightEyeTransform, rightVerticalAngleInRadians, 1.0, 0.0, 0.0);

    [self.eyesViewController setLeftEyeTransform:leftEyeTransform];
    [self.eyesViewController setRightEyeTransform:rightEyeTransform];
}

@end
