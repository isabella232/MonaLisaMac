//
//  MLOverlayView 
//  MonaLisaMac
//
//  Created by brandon on 10/22/2013.
//  Copyright (c) 2013 Robots and Pencils Inc. All rights reserved.
//
//  Draws a face and feature frame outline to be placed over a video where faces may be detected
//

@interface MLOverlayView : NSView

@property (nonatomic, strong) NSArray *faces;
@property (nonatomic) CGSize capturedImageSize;

@end
