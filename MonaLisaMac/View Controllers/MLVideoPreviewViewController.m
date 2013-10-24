//
//  MLVideoPreviewViewController.m
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLVideoPreviewViewController.h"

@interface MLVideoPreviewViewController ()

@end

@implementation MLVideoPreviewViewController

- (id)initWithCaptureSession:(AVCaptureSession *)session {
    if (!(self = [super initWithNibName:@"MLVideoPreviewView" bundle:nil])) return nil;
    [self loadView];

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    self.videoPreviewView.wantsLayer = YES;
    self.previewLayer.frame = self.videoPreviewView.bounds;
    [self.videoPreviewView.layer addSublayer:self.previewLayer];

    self.overlayView.frame = self.videoPreviewView.frame;

    return self;
}

- (void)updateFaces:(NSArray *)faces inImageSize:(NSSize)size {
    self.overlayView.faces = faces;
    self.overlayView.capturedImageSize = size;
    [self.overlayView display];
}

@end
