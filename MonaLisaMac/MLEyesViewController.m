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

@property (strong, nonatomic) SCNMaterial *leftNormalMaterial;
@property (strong, nonatomic) SCNMaterial *rightNormalMaterial;
@property (strong, nonatomic) SCNMaterial *leftAlternateMaterial;
@property (strong, nonatomic) SCNMaterial *rightAlternateMaterial;

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

    SCNSphere *sphereGeomLeft = [SCNSphere sphereWithRadius:12];
    self.leftEyeNode = [SCNNode nodeWithGeometry:sphereGeomLeft];
    self.leftEyeNode.position = SCNVector3Make(-15, 0.0, 0.0);
    [root addChildNode:self.leftEyeNode];
    self.originalLeftEyeTransform = self.leftEyeNode.transform;

    SCNSphere *sphereGeomRight = [SCNSphere sphereWithRadius:12];
    self.rightEyeNode = [SCNNode nodeWithGeometry:sphereGeomRight];
    self.rightEyeNode.position = SCNVector3Make(18, 0.0, 0.0);
    [root addChildNode:self.rightEyeNode];
    self.originalRightEyeTransform = self.rightEyeNode.transform;

    NSImage *diffuseImage = [NSImage imageNamed:@"leftEye"];
    self.leftNormalMaterial = [SCNMaterial material];
    self.leftNormalMaterial.diffuse.contents  = diffuseImage;
    self.leftNormalMaterial.specular.contents = [NSColor whiteColor];
    self.leftNormalMaterial.shininess = 1.0;
    self.leftNormalMaterial.diffuse.contentsTransform = CATransform3DMakeTranslation(-0.02,0,0);
    sphereGeomLeft.materials = @[self.leftNormalMaterial];
    self.rightNormalMaterial = [self.leftNormalMaterial copy];
    diffuseImage = [NSImage imageNamed:@"rightEye"];
    self.rightNormalMaterial.diffuse.contents = diffuseImage;
    self.rightNormalMaterial.diffuse.contentsTransform = CATransform3DMakeTranslation(0.09,0,0);
    sphereGeomRight.materials = @[self.rightNormalMaterial];

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

- (void)showAlternateEye:(BOOL)showAlternate {
    if (showAlternate) {
        self.leftEyeNode.geometry.materials = @[ self.leftAlternateMaterial ];
        self.rightEyeNode.geometry.materials = @[ self.rightAlternateMaterial ];
    }
    else {
        self.leftEyeNode.geometry.materials = @[ self.leftNormalMaterial ];
        self.rightEyeNode.geometry.materials = @[ self.rightNormalMaterial ];
    }
}

@end
