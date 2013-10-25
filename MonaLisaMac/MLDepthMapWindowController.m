//
//  MLDepthMapWindowController.m
//  MonaLisaMac
//
//  Created by Brandon on 10/25/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLDepthMapWindowController.h"
#import "DepthView.h"

@interface MLDepthMapWindowController ()

@property (weak) IBOutlet DepthView *depthView;

@end

@implementation MLDepthMapWindowController

- (void)update {
    [self.depthView setNeedsDisplay:YES];
}

@end
