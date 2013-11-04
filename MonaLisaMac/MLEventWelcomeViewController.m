//
//  MLEventWelcomeViewController.m
//  MonaLisaMac
//
//  Created by Brandon on 11/4/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLEventWelcomeViewController.h"

@interface MLEventWelcomeViewController ()

@property (weak) IBOutlet NSTextField *clientNameLabel;
@property (weak) IBOutlet NSTextField *eventLocationLabel;
@property (weak) IBOutlet NSImageView *clientLogoLabel;

@end

@implementation MLEventWelcomeViewController

- (void)viewDidLoad {
    self.clientNameLabel.font = [NSFont fontWithName:@"Interstate-Bold" size:self.clientNameLabel.font.pointSize];
    self.eventLocationLabel.font = [NSFont fontWithName:@"Interstate-Regular" size:self.clientNameLabel.font.pointSize];

    [self.clientNameLabel setStringValue:@"Welcome Ross and Andre."];

    NSString *eventInfo = @"Lower Boardroom";
    eventInfo = [eventInfo stringByAppendingString:@" • "];
    eventInfo = [eventInfo stringByAppendingString:@"3pm"];

    [self.eventLocationLabel setStringValue:eventInfo];

    self.clientLogoLabel.image = [NSImage imageNamed:@"client_logo"];
}

- (void)loadView {
    [super loadView];
    [self viewDidLoad];
}

@end
