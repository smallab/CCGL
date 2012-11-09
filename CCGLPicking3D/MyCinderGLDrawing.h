//
//  MyController.mm
//  CCGLPicking3D example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//
//  This example is based on Paul Houx's great Picking3D sample included in Cinder's
//  distribution
//  

#include "CCGLView.h"

#include "cinder/Camera.h"
#include "cinder/MayaCamUI.h"
#include "cinder/gl/Texture.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/ImageIo.h"
#include "cinder/Rand.h"
#include "cinder/TriMesh.h"
#include "Resources.h"

#include <vector>
#include <utility>

@interface MyCinderGLDrawing : CCGLView
{
	MayaCamUI mMayaCam;
	int mCubeSize;

	// shader and texture for our model
	gl::GlslProg	mShader;
	gl::Texture		mTexture;
    
	// the model of a rubber ducky
	TriMesh		mMesh;
    
	// transformations (translate, rotate, scale) of the model
	Matrix44f	mTransform;
    
	// keep track of the mouse
	Vec2i		mMousePos;
    
	// keep track of time
	double		mTime;
}

/**
 *  Custom drawing methods
 */

void drawGrid(float size, float step);
- (void) animateDuck;
- (bool) performPickingWith:(Vec3f *) pickedPoint And:(Vec3f *) pickedNormal;

@end
