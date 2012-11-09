//
//  MyCinderGLDrawing.h
//  CCGLParticles example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#include "CCGLView.h"

#include "cinder/Camera.h"
#include "cinder/MayaCamUI.h"
#include "cinder/TriMesh.h"
#include "cinder/ObjLoader.h"
#include "cinder/gl/Texture.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/ImageIo.h"
#include "Resources.h"

#include "ParticleController.h"


// GLOBAL VARS
double      mTime;
int         mPAmount;


@interface MyCinderGLDrawing : CCGLView
{
	MayaCamUI mMayaCam;
    
    // particle
    ParticleController		mParticleController;

	// shader and texture for our model
	gl::GlslProg	mShader;
	gl::Texture		mTexture;
}

/**
 *  Cocoa UI methods
 */

- (void) setParticleAmount: (int) value;

@end
