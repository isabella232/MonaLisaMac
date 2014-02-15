//
//  MLPreferencesViewController.m
//  MonaLisaMac
//
//  Created by Brandon on 2/14/2014.
//  Copyright (c) 2014 RobotsAndPencils. All rights reserved.
//

#import "MLPreferencesViewController.h"

@interface MLPreferencesViewController ()

@end

@implementation MLPreferencesViewController

- (NSString *)identifier {
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel {
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}


@end
