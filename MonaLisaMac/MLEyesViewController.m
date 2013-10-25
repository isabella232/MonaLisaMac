//
//  MLEyesViewController.m
//  MonaLisaMac
//
//  Created by Brandon on 10/24/2013.
//  Copyright (c) 2013 RobotsAndPencils. All rights reserved.
//

#import "MLEyesViewController.h"
#import <SceneKit/SceneKit.h>

@interface MLEyesViewController ()

@property (strong, nonatomic) SCNNode *leftEyeNode;
@property (strong, nonatomic) SCNNode *rightEyeNode;

@property (nonatomic) CATransform3D originalLeftEyeTransform;
@property (nonatomic) CATransform3D originalRightEyeTransform;

@end

@implementation MLEyesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) return nil;
    [self loadView];
    return self;
}

- (void)awakeFromNib {
    SCNView *sceneView = (SCNView *)self.view;
    sceneView.backgroundColor = [NSColor clearColor];

    // Create the scene and get the root
    sceneView.scene = [SCNScene scene];
    SCNNode *root = sceneView.scene.rootNode;

    SCNSphere *sphereGeomLeft = [SCNSphere sphereWithRadius:7];
    self.leftEyeNode = [SCNNode nodeWithGeometry:sphereGeomLeft];
    self.leftEyeNode.position = SCNVector3Make(-15, 0.0, 0.0);
    [root addChildNode:self.leftEyeNode];
    self.originalLeftEyeTransform = self.leftEyeNode.transform;

    SCNSphere *sphereGeomRight = [SCNSphere sphereWithRadius:7];
    self.rightEyeNode = [SCNNode nodeWithGeometry:sphereGeomRight];
    self.rightEyeNode.position = SCNVector3Make(15, 0.0, 0.0);
    [root addChildNode:self.rightEyeNode];
    self.originalRightEyeTransform = self.rightEyeNode.transform;

    SCNMaterial *material = [SCNMaterial material];
    NSImage *diffuseImage = [NSImage imageNamed:@"eye"];
    material.diffuse.contents  = diffuseImage;
    material.specular.contents = [NSColor whiteColor];
    material.shininess = 1.0;
    material.diffuse.contentsTransform = CATransform3DMakeTranslation(-0.10,0,0);
    sphereGeomLeft.materials = @[material];
    SCNMaterial *materialRight = [material copy];
    materialRight.diffuse.contentsTransform = CATransform3DMakeTranslation(0.05,0,0);
    sphereGeomRight.materials = @[materialRight];

    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 0, 30);
    [root addChildNode:cameraNode];
}

- (void)setLeftEyeTransform:(CATransform3D)transform {
    self.leftEyeNode.transform = CATransform3DConcat(transform, self.originalLeftEyeTransform);
}

- (void)setRightEyeTransform:(CATransform3D)transform {
    self.rightEyeNode.transform = CATransform3DConcat(transform, self.originalRightEyeTransform);
}

@end
