//
//  MLMonaLisaWindowController.m
//  MonaLisaMac
//
//  Created by Brandon on 10/24/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLMonaLisaWindowController.h"
#import "MLEyesViewController.h"

static CGFloat M_PI_3 = M_PI / 3.0;
static CGFloat M_PI_6 = M_PI / 6.0;

CGFloat map(CGFloat x, CGFloat in_min, CGFloat in_max, CGFloat out_min, CGFloat out_max) {
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

@interface MLMonaLisaWindowController ()

@property (strong, nonatomic) IBOutlet NSImageView *monaLisaImageView;
@property (strong, nonatomic) IBOutlet NSImageView *leftEyeImageView;
@property (strong, nonatomic) IBOutlet NSImageView *rightEyeImageView;

@property (strong, nonatomic) MLEyesViewController *eyesViewController;

@property (nonatomic) CGPoint originalLeftEyeOrigin;
@property (nonatomic) CGPoint originalRightEyeOrigin;

@end

@implementation MLMonaLisaWindowController

- (void)windowDidLoad {
    self.eyesViewController = [[MLEyesViewController alloc] initWithNibName:@"MLEyesView" bundle:nil];
    self.eyesViewController.view.frame = CGRectMake(350, 520, 250, 150);
    [self.window.contentView addSubview:self.eyesViewController.view positioned:NSWindowBelow relativeTo:self.monaLisaImageView];
}

- (void)awakeFromNib {

}

- (NSSize)window:(NSWindow *)window willUseFullScreenContentSize:(NSSize)proposedSize {
    CGFloat width = fmin(proposedSize.width, self.monaLisaImageView.frame.size.width);
    CGFloat height = fmin(proposedSize.height, self.monaLisaImageView.frame.size.width);
    CGFloat x = (proposedSize.width - width) / 2;
    CGFloat y = (proposedSize.height - height) / 2;

    self.monaLisaImageView.frame = CGRectMake(x, y, width, height);
    
    return proposedSize;
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
