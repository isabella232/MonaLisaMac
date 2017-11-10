//
//  MLAppDelegate.m
//  MonaLisaMac
//
//  Created by Brandon on 10/22/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLAppDelegate.h"
#import "CocoaOpenNI.h"
#import "DepthView.h"
#import "NSTimer+BlocksKit.h"
#import "Skeleton.h"
#import "MLXnVector3DSmoother.h"
#import "MLMonaLisaWindowController.h"
#import "MLDepthMapWindowController.h"
#import "MLXnVector3DSmoother.h"
#import "MLPreferencesViewController.h"
#import "MASPreferencesWindowController.h"

NSString * const MLEyeXPositionKey = @"MLEyeXPositionKey";
NSString * const MLEyeYPositionKey = @"MLEyeYPositionKey";
NSString * const MLEyeWidthKey = @"MLEyeWidthKey";
NSString * const MLEyeHeightKey = @"MLEyeHeightKey";

@interface MLAppDelegate ()

@property (strong, nonatomic) MLMonaLisaWindowController *monaLisaWindowController;
@property (strong, nonatomic) MLDepthMapWindowController *depthMapWindowController;
@property (strong, nonatomic, readonly) NSWindowController *preferencesWindowController;
@property (strong, nonatomic) MLXnVector3DSmoother *smoother;

@property (strong, nonatomic) NSTimer *changeUserTimer;
@property (nonatomic) XnUserID currentlyTrackedUserID;

@end

@implementation MLAppDelegate

@synthesize preferencesWindowController = _preferencesWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.currentlyTrackedUserID = INT32_MAX;
    [self setupDefaults];

    CocoaOpenNI *openNI = [CocoaOpenNI sharedOpenNI];
    if (openNI) {
        [self setupOpenNI:openNI];
    }

    [self showMonaLisa:nil];
}

#pragma mark - Actions

- (IBAction)showDepthImage:(id)sender {
    self.depthMapWindowController = [[MLDepthMapWindowController alloc] initWithWindowNibName:@"MLDepthMapWindow"];
    [self.depthMapWindowController showWindow:nil];
    [self.depthMapWindowController.window makeMainWindow];
}

- (IBAction)showMonaLisa:(id)sender {
    self.monaLisaWindowController = [[MLMonaLisaWindowController alloc] initWithWindowNibName:@"MLMonaLisaWindow"];
    [self.monaLisaWindowController showWindow:nil];
    [self.monaLisaWindowController.window makeMainWindow];
    [self.monaLisaWindowController.window toggleFullScreen:nil];
}

- (IBAction)openPreferences:(id)sender {
    [self.preferencesWindowController showWindow:nil];
}

#pragma mark - Private

- (void)setupDefaults {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)setupOpenNI:(CocoaOpenNI *)openNI {
    [openNI startWithConfigPath:[[NSBundle mainBundle] pathForResource:@"KinectConfig" ofType:@"xml"]];

    [NSTimer bk_scheduledTimerWithTimeInterval:1.0 / 30.0 block:^(NSTimer *timer) {
        if ([CocoaOpenNI sharedOpenNI].started) {
            // Sometimes we get a crash in here
            [[CocoaOpenNI sharedOpenNI] context].WaitAndUpdateAll();
            [self.depthMapWindowController update];
        }

        // Haven't found a skeleton yet or previous skeleton is invalid
        BOOL currentSkeletonIsInvalid = ![[[CocoaOpenNI sharedOpenNI].skeletons allKeys] containsObject:@(self.currentlyTrackedUserID)];
        if (self.currentlyTrackedUserID == INT32_MAX || currentSkeletonIsInvalid) {
            self.currentlyTrackedUserID = [[CocoaOpenNI sharedOpenNI] firstTrackedUser];
        }
        if (self.currentlyTrackedUserID == INT32_MAX) return;

        // Schedule the self-repeating timer to loop through users
        if (!self.changeUserTimer) {
            [self createChangeUserTimer];
        }

        Skeleton *firstSkeleton = [CocoaOpenNI sharedOpenNI].skeletons[@(self.currentlyTrackedUserID)];
        XnVector3D position = firstSkeleton.head.position;

        if (!self.smoother) {
            self.smoother = [[MLXnVector3DSmoother alloc] initWithVector:position interval:0.1];
        }
        else {
            position = [self.smoother smooth:position];
        }

        if (self.monaLisaWindowController) {
            [self.monaLisaWindowController updateEyeLocationWithHeadPosition:position];
        }
    } repeats:YES];
    
    [self showDepthImage:nil];
}

- (NSWindowController *)preferencesWindowController {
    if (!_preferencesWindowController) {
        NSViewController *preferencesViewController = [[MLPreferencesViewController alloc] initWithNibName:@"MLPreferencesView" bundle:nil];
        NSArray *controllers = @[ preferencesViewController ];

        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    return _preferencesWindowController;
}

- (void)createChangeUserTimer {
    NSInteger duration = 1 + arc4random_uniform(3);
    self.changeUserTimer = [NSTimer bk_scheduledTimerWithTimeInterval:duration block:^(NSTimer *timer) {

        // Increment the userID and loop if past bounds
        XnInt16 userCount = [[CocoaOpenNI sharedOpenNI] userGenerator].GetNumberOfUsers();
        if (userCount == 0) {
            self.currentlyTrackedUserID = INT32_MAX;
            self.changeUserTimer = nil;
            return;
        }

        ++self.currentlyTrackedUserID;
        if (self.currentlyTrackedUserID > userCount) {
            self.currentlyTrackedUserID = 1;
        }

        [self createChangeUserTimer];
    } repeats:NO];
}

@end
