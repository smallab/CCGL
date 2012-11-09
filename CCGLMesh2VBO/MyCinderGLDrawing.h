//
//  MyCinderGLDrawing.h
//  CCGLMesh2VBO example
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
#include "cinder/ObjLoader.h"
#include "cinder/TriMesh.h"
#include "cinder/gl/Texture.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/ImageIo.h"
#include "cinder/gl/Vbo.h"
#include "Resources.h"

#include <vector>
#include <utility>

@interface MyCinderGLDrawing : CCGLView
{
	MayaCamUI mMayaCam;

    TriMesh mMesh;

	int mXFactor;

    // VBOs
	int VERTICES_X;
    int VERTICES_Z;
	gl::VboMesh		mVboMesh;
    
	// shader and texture for our model
	gl::GlslProg	mShader;
	gl::Texture		mTexture;
}

/**
 *  Custom drawing methods
 */

void animateVertices(float mTime, gl::VboMesh &vboMesh, TriMesh &mesh, int xFactor);

/**
 *  Cocoa UI methods
 */

- (void) setXFactor: (int) factor;

@end
