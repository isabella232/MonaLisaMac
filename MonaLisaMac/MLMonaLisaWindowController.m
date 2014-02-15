//
//  MLMonaLisaWindowController.m
//  MonaLisaMac
//
//  Created by Brandon on 10/24/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLMonaLisaWindowController.h"
#import "MLEyesViewController.h"
#import "NSTimer+BlocksKit.h"
#import "NSObject+BlocksKit.h"
#import "MLEventWelcomeViewController.h"

static CGFloat M_PI_6 = M_PI / 6.0;

CGRect CGRectCenteredInCGRect(CGRect inner, CGRect outer) {
    return CGRectMake((outer.size.width - inner.size.width) / 2.0, (outer.size.height - inner.size.height) / 2.0, inner.size.width, inner.size.height);
}

CGRect CGRectFromCGSize(CGSize size) {
    return CGRectMake(0, 0, size.width, size.height);
}

CGSize CGSizeScale(CGSize size, CGFloat xScale, CGFloat yScale) {
    return CGSizeMake(size.width * xScale, size.height * yScale);
}

@interface MLMonaLisaWindowController ()

@property (strong, nonatomic) IBOutlet NSImageView *monaLisaImageView;
@property (strong, nonatomic) MLEyesViewController *eyesViewController;
@property (strong, nonatomic) NSImage *normalImage;
@property (strong, nonatomic) NSImage *alternateImage;
@property (strong, nonatomic) NSTimer *imageFlickerTimer;
@property (strong, nonatomic) MLEventWelcomeViewController *eventWelcomeViewController;

@property (nonatomic) CGRect originalEyeFrame;
@property (nonatomic) CGSize originalMonaLisaSize;
@property (nonatomic) NSInteger flickerBurst;
@property (nonatomic) XnVector3D headPosition;

@end

@implementation MLMonaLisaWindowController

#pragma mark - NSWindowController

- (void)windowDidLoad {
    self.eyesViewController = [[MLEyesViewController alloc] initWithNibName:@"MLEyesView" bundle:nil];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EyesFrame" ofType:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    self.eyesViewController.view.frame = CGRectMake([data[@"x"] floatValue], [data[@"y"] floatValue], [data[@"width"] floatValue], [data[@"height"] floatValue]);
    self.eyesViewController.view.layer.autoresizingMask = kCALayerNotSizable | kCALayerMaxXMargin;
    [self.window.contentView addSubview:self.eyesViewController.view positioned:NSWindowBelow relativeTo:self.monaLisaImageView];

    self.normalImage = self.monaLisaImageView.image;
    self.alternateImage = [NSImage imageNamed:@"mona_lisa_cyborg"];

    ((NSView *)self.window.contentView).layer.backgroundColor = [NSColor blackColor].CGColor;

    self.originalEyeFrame = self.eyesViewController.view.frame;
    self.originalMonaLisaSize = CGSizeMake(1080, 1920);

    [self resizeMonaLisaForWindowSize:self.window.frame.size];
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
    NSWindow *window = notification.object;
    [self resizeMonaLisaForWindowSize:window.frame.size];
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification {
    NSWindow *window = notification.object;
    [self resizeMonaLisaForWindowSize:window.frame.size];
}

- (void)windowDidChangeScreen:(NSNotification *)notification {
    NSWindow *window = notification.object;
    [self resizeMonaLisaForWindowSize:window.frame.size];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)windowSize {
    [self resizeMonaLisaForWindowSize:windowSize];
    return windowSize;
}

#pragma mark - Private

- (void)resizeMonaLisaForWindowSize:(NSSize)windowSize {
    CGFloat sx = self.monaLisaImageView.frame.size.width / self.monaLisaImageView.image.size.width;
    CGFloat sy = self.monaLisaImageView.frame.size.height / self.monaLisaImageView.image.size.height;
    CGFloat s = fmin(sx, sy);
    CGSize scale = CGSizeMake(s, s);

    CGRect imageDisplayRect = CGRectCenteredInCGRect(CGRectFromCGSize(CGSizeScale(self.monaLisaImageView.image.size, scale.width, scale.height)), self.monaLisaImageView.frame);

    CGFloat xScale = imageDisplayRect.size.width / self.originalMonaLisaSize.width;
    CGFloat yScale = imageDisplayRect.size.height / self.originalMonaLisaSize.height;

    CGRect newEyeFrame = self.eyesViewController.view.frame;
    newEyeFrame.origin.x = CGRectGetMinX(self.monaLisaImageView.frame) + CGRectGetMinX(imageDisplayRect) + self.originalEyeFrame.origin.x * xScale;
    newEyeFrame.origin.y = CGRectGetMinY(self.monaLisaImageView.frame) + CGRectGetMinY(imageDisplayRect) + self.originalEyeFrame.origin.y * yScale;
    newEyeFrame.size.width = self.originalEyeFrame.size.width * xScale;
    newEyeFrame.size.height = self.originalEyeFrame.size.height * yScale;
    self.eyesViewController.view.frame = newEyeFrame;

    self.eventWelcomeViewController.view.frame = imageDisplayRect;
}

- (void)updateEyeLocationWithHeadPosition:(XnVector3D)headPosition {
    CGFloat monaLisaEyeSeparationInMM = 60.0f;
    self.headPosition = headPosition;

    headPosition.Y += 150.f;

    //Calculate angle from eye to face based on face position
    CGFloat leftHorizontalAngleInRadians = atan((monaLisaEyeSeparationInMM / 2 + headPosition.X) / headPosition.Z) / 2;
    CGFloat leftVerticalAngleInRadians = -atan(headPosition.Y / headPosition.Z) / 3;
    CGFloat rightHorizontalAngleInRadians = -atan((monaLisaEyeSeparationInMM / 2 - headPosition.X) / headPosition.Z) / 2;
    CGFloat rightVerticalAngleInRadians = -atan(headPosition.Y / headPosition.Z) / 3;

    // Horizontal movement of human eye is ~90deg
    // Vertical movement of human eye is ~60deg
    leftHorizontalAngleInRadians = fmax(-M_PI_4, fmin(leftHorizontalAngleInRadians, M_PI_4));
    leftVerticalAngleInRadians = fmax(-M_PI_6, fmin(leftVerticalAngleInRadians, M_PI_6));
    rightHorizontalAngleInRadians = fmax(-M_PI_4, fmin(rightHorizontalAngleInRadians, M_PI_4));
    rightVerticalAngleInRadians = fmax(-M_PI_6, fmin(rightVerticalAngleInRadians, M_PI_6));

    CATransform3D leftEyeTransform = CATransform3DMakeRotation(leftHorizontalAngleInRadians, 0.0, 1.0, 0.0);
    leftEyeTransform = CATransform3DRotate(leftEyeTransform, leftVerticalAngleInRadians, 1.0, 0.0, 0.0);

    CATransform3D rightEyeTransform = CATransform3DMakeRotation(rightHorizontalAngleInRadians, 0.0, 1.0, 0.0);
    rightEyeTransform = CATransform3DRotate(rightEyeTransform, rightVerticalAngleInRadians, 1.0, 0.0, 0.0);

    [self.eyesViewController setLeftEyeTransform:leftEyeTransform];
    [self.eyesViewController setRightEyeTransform:rightEyeTransform];
}

- (void)showEventWelcomeView {
    if (!self.eventWelcomeViewController) {
        self.eventWelcomeViewController = [[MLEventWelcomeViewController alloc] initWithNibName:@"MLEventWelcomeView" bundle:nil];
    }
    [self.window.contentView addSubview:self.eventWelcomeViewController.view];
}

@end
