//
//  MyCinderGLDrawing.h
//  CCGLOSCBlock example
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

#include "OscListener.h"
#include "OscSender.h"

@interface MyCinderGLDrawing : CCGLView
{
	MayaCamUI mMayaCam;
	float mRed;

    // OSC vars
	osc::Listener listener;
	osc::Sender sender;
	std::string host;
	int port;
}

/**
 *  Cocoa UI methods
 */

- (void) setOSCoutput: (int) value;

/**
 *  Custom OSC methods
 */

- (void) initOSC;
- (void) receiveOSC;
- (void) propagate2OSC: (int) output;

@end
