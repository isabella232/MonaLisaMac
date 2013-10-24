//
//  MLVideoPreviewViewController.h
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLOverlayView.h"
#import <AVFoundation/AVFoundation.h>

@interface MLVideoPreviewViewController : NSViewController

@property (weak) IBOutlet NSView *videoPreviewView;
@property (weak) IBOutlet MLOverlayView *overlayView;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (id)initWithCaptureSession:(AVCaptureSession *)session;
- (void)updateFaces:(NSArray *)faces inImageSize:(NSSize)size;

@end
