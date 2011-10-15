//
//  MyCinderGLDrawing.h
//  CCGLBlobDetection example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://www.smallab.org/code/ccgl/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#include "CCGLView.h"

#include "cinder/Camera.h"
#include "cinder/MayaCamUI.h"
#include "cinder/gl/Texture.h"
#include "cinder/Capture.h"
#include "cinder/Rand.h"

#include "CinderOpenCV.h"

@interface MyCinderGLDrawing : CCGLView
{
	MayaCamUI       mMayaCam;
	
	Capture			mCap;
	gl::Texture		mTexture;
    int             mWidth, mHeight;
    size_t          mLevels;
    int             m3D;
    boolean_t       mDrawCapture;
    std::vector< std::vector< std::vector<cv::Point> > > mCvContours;
}

/**
 *  Cocoa UI methods
 */

- (void) setBlobLevels: (int) levels;
- (void) set3dEffect: (int) effect;
- (void) resetCamera;
- (void) showFeed:(bool)show;

@end
