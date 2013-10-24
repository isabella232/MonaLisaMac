//
//  MLHeadPositionDetector.m
//  MonaLisaMac
//
//  Created by Brandon on 10/23/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MLHeadPositionDetector.h"
#import "MLHeadPosition.h"
#import "MLHeadPositionSmoother.h"

@interface MLHeadPositionDetector () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) MLHeadPositionSmoother *smoother;

@end

@implementation MLHeadPositionDetector

- (id)init {
    if (!(self = [super init])) return nil;

    _session = [self setupCaptureSession];

    return self;
}

- (AVCaptureSession *)setupCaptureSession {
    NSError *error = nil;

    // Create the session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;

    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [session addInput:input];

    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:output];

    // Get focal length
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG };
    [stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:stillImageOutput];

    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {break;}
    }

    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments) {
            NSLog(@"%@", exifAttachments);
        }
    }];

    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];

    // Specify the pixel format
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];

    // If you wish to cap the frame rate to a known value, such as 15 fps, set
    // minFrameDuration.
    //output.minFrameDuration = CMTimeMake(1, 15);

    // Start the session running to start the flow of data
    [session startRunning];
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];

    return session;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    NSArray *faces = [self.faceDetector featuresInImage:image];
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:image];

    if (self.foundFacesBlock) self.foundFacesBlock(faces, rep.size);

    CIFaceFeature *face = [self getFaceInFrameLongestFromFaces:faces];
    if (face) {
        // Run the positioning in the background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            MLHeadPosition *headPosition = [MLHeadPosition headPositionOfCIFaceFeature:face cameraFieldOfView:80.0f cameraOffsetFromScreen:CGSizeMake(0, 0) detectedImageSize:rep.size];
            if (!self.smoother) {
                self.smoother = [[MLHeadPositionSmoother alloc] initWithHeadPosition:headPosition interval:0.15];
            }
            MLHeadPosition *smoothedPosition = [self.smoother smooth:headPosition];

            if (self.foundPrimaryHeadPositionBlock) self.foundPrimaryHeadPositionBlock(smoothedPosition);
        });
    }
}

#pragma mark - Private

- (CIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
            bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // Create an image object from the Quartz image
    CIImage *image = [CIImage imageWithCGImage:quartzImage];

    // Release the Quartz image
    CGImageRelease(quartzImage);

    return image;
}

- (CIFaceFeature *)getFaceInFrameLongestFromFaces:(NSArray *)faces {
    if (!faces || [faces count] == 0) return nil;

    faces = [faces sortedArrayUsingComparator:^NSComparisonResult(CIFaceFeature *face1, CIFaceFeature *face2) {
        if (![face1 hasTrackingFrameCount] && [face2 hasTrackingFrameCount]) return NSOrderedAscending;
        if ([face1 hasTrackingFrameCount] && ![face2 hasTrackingFrameCount]) return NSOrderedDescending;
        if (![face1 hasTrackingFrameCount] && ![face2 hasTrackingFrameCount]) return NSOrderedSame;

        if (face1.trackingFrameCount < face2.trackingFrameCount) return NSOrderedAscending;
        if (face1.trackingFrameCount > face2.trackingFrameCount) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    CIFaceFeature *longestFaceInFrame = faces[0];
    return longestFaceInFrame;
}

@end
