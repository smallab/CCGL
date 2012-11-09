//
//  MyCinderGLDrawing.h
//  CCGLObj2Mesh example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#include "CCGLView.h"

#include "Resources.h"

#include "cinder/Camera.h"
#include "cinder/MayaCamUI.h"
#include "cinder/ImageIo.h"
#include "cinder/TriMesh.h"
#include "cinder/ObjLoader.h"
#include "cinder/Sphere.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/gl/Vbo.h"
#include "cinder/gl/Texture.h"

@interface MyCinderGLDrawing : CCGLView
{
	MayaCamUI mMayaCam;
    bool mAnimationFlag;
    TriMesh mMesh;
	gl::VboMesh		mVBO;
	gl::GlslProg	mShader;
	gl::Texture		mTexture;
}

@end
