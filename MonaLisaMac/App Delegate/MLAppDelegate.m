//
//  MLAppDelegate.m
//  MonaLisaMac
//
//  Created by Brandon on 10/22/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLAppDelegate.h"
#import "MLHeadPosition.h"
#import <AVFoundation/AVFoundation.h>
#import "MLVideoPreviewViewController.h"
#import "MLHeadPositionDetector.h"

@interface MLAppDelegate () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet NSImageView *monaLisaImageView;
@property (weak, nonatomic) IBOutlet NSImageView *leftEyeImageView;
@property (weak, nonatomic) IBOutlet NSImageView *rightEyeImageView;

@property (nonatomic, strong) MLHeadPositionDetector *headPositionDetector;
@property (strong, nonatomic) MLVideoPreviewViewController *videoPreviewViewController;

@property (nonatomic) CGPoint originalLeftEyeOrigin;
@property (nonatomic) CGPoint originalRightEyeOrigin;

@end

CGFloat map(CGFloat x, CGFloat in_min, CGFloat in_max, CGFloat out_min, CGFloat out_max) {
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

static CGFloat M_PI_3 = M_PI / 3.0;
static CGFloat M_PI_6 = M_PI / 6.0;

@implementation MLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.headPositionDetector = [[MLHeadPositionDetector alloc] init];

    __weak __typeof(self) _self = self;
    self.headPositionDetector.foundFacesBlock = ^(NSArray *faces, NSSize imageSize){
        [_self.videoPreviewViewController updateFaces:faces inImageSize:imageSize];
    };
    self.headPositionDetector.foundPrimaryHeadPositionBlock = ^(MLHeadPosition *smoothedPosition) {
        [_self updateEyeLocationWithHeadPosition:smoothedPosition];
    };

    self.monaLisaImageView.layer.backgroundColor = [NSColor clearColor].CGColor;
    [self.window.contentView addSubview:self.leftEyeImageView positioned:NSWindowBelow relativeTo:self.monaLisaImageView];
    [self.window.contentView addSubview:self.rightEyeImageView positioned:NSWindowBelow relativeTo:self.monaLisaImageView];

    self.originalLeftEyeOrigin = self.leftEyeImageView.frame.origin;
    self.originalRightEyeOrigin = self.rightEyeImageView.frame.origin;

    self.videoPreviewViewController = [[MLVideoPreviewViewController alloc] initWithCaptureSession:self.headPositionDetector.session];
    self.videoPreviewViewController.view.frame = CGRectMake(0,0,480,320);
    [self.window.contentView addSubview:self.videoPreviewViewController.view];
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification {

}

- (void)windowWillExitFullScreen:(NSNotification *)notification {

}

#pragma mark - Private

- (void)updateEyeLocationWithHeadPosition:(MLHeadPosition *)headPosition {
    CGFloat monaLisaEyeSeparationInCM = 4.0f;
    CGFloat maximumHorizontalEyeMovementInPX = 8.0f;
    CGFloat maximumVerticalEyeMovementInPX = 5.0f;

    //Calculate angle from eye to face based on face position
    CGFloat leftHorizontalAngleInRadians = atan((monaLisaEyeSeparationInCM / 2 + headPosition.x) / headPosition.z);
    CGFloat leftVerticalAngleInRadians = -atan(headPosition.y / headPosition.z);
    CGFloat rightHorizontalAngleInRadians = -atan((monaLisaEyeSeparationInCM / 2 - headPosition.x) / headPosition.z);
    CGFloat rightVerticalAngleInRadians = -atan(headPosition.y / headPosition.z);

    // Horizontal movement of human eye is ~90deg
    // Vertical movement of human eye is ~60deg
    leftHorizontalAngleInRadians = fmax(-M_PI_4, fmin(leftHorizontalAngleInRadians, M_PI_4));
    leftVerticalAngleInRadians = fmax(-M_PI_6, fmin(leftVerticalAngleInRadians, M_PI_6));
    rightHorizontalAngleInRadians = fmax(-M_PI_4, fmin(rightHorizontalAngleInRadians, M_PI_2));
    rightVerticalAngleInRadians = fmax(-M_PI_6, fmin(rightVerticalAngleInRadians, M_PI_6));

    // Scale eye position based on angle
    CGFloat leftEyeXDelta = map(leftHorizontalAngleInRadians, -M_PI_4, M_PI_4, -maximumHorizontalEyeMovementInPX, maximumHorizontalEyeMovementInPX);
    CGFloat leftEyeYDelta = map(leftVerticalAngleInRadians, -M_PI_3, M_PI_3, -maximumVerticalEyeMovementInPX, maximumVerticalEyeMovementInPX);
    CGFloat rightEyeXDelta = map(rightHorizontalAngleInRadians, -M_PI_4, M_PI_4, -maximumHorizontalEyeMovementInPX, maximumHorizontalEyeMovementInPX);
    CGFloat rightEyeYDelta = map(rightVerticalAngleInRadians, -M_PI_3, M_PI_3, -maximumVerticalEyeMovementInPX, maximumVerticalEyeMovementInPX);

    CGFloat leftEyeX = self.originalLeftEyeOrigin.x + leftEyeXDelta;
    CGFloat leftEyeY = self.originalLeftEyeOrigin.y + leftEyeYDelta;
    CGFloat rightEyeX = self.originalRightEyeOrigin.x + rightEyeXDelta;
    CGFloat rightEyeY = self.originalRightEyeOrigin.y + rightEyeYDelta;

    CGPoint newLeftOrigin = CGPointMake(leftEyeX, leftEyeY);
    CGPoint newRightOrigin = CGPointMake(rightEyeX, rightEyeY);

    // Update the UI on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.leftEyeImageView setFrameOrigin:newLeftOrigin];
        [self.rightEyeImageView setFrameOrigin:newRightOrigin];
    });                 
}

@end
