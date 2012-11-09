//
//  MyCinderGLDrawing.h
//  CCGLLights example
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

@interface MyCinderGLDrawing : CCGLView
{
	MayaCamUI mMayaCam;
	int mCubeSize;
    int mMatSpec;
}

/**
 *  Custom drawing methods
 */

- (void) someLights;
void drawGrid(float size, float step);

/**
 *  Cocoa UI methods
 */

- (void) setCubeSize: (int) size;
- (void) setMatSpec: (int) matSpec;

@end
