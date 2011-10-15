//
//  MyCinderGLDrawing.mm
//  CCGLOSCBlock example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://www.smallab.org/code/ccgl/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#import "MyCinderGLDrawing.h"

@implementation MyCinderGLDrawing

/**
 *  The superclass setup method
 */

- (void) setup
{
	[super setup];
	
	// setup our camera
	CameraPersp cam;
	/*cam.lookAt( Vec3f( -100, 10, 10 ), Vec3f::zero() );*/
	cam.setEyePoint( Vec3f(-100.0f, 10.0f, 10.0f) );
	cam.setCenterOfInterestPoint( Vec3f(0.0f, 0.0f, 0.0f) );
	cam.setPerspective( 60.0f, [self getWindowAspectRatio], 1.0f, 1000.0f );
	mMayaCam.setCurrentCam( cam );
	
	// set initial value
    mRed = 0.0f;
    
    // initialize OSC
    [self initOSC];
}



/**
 *  The superclass draw loop method
 */

- (void) draw
{
    // receive OSC msgs
    [self receiveOSC];
    
	// use the camera 
	gl::setMatrices( mMayaCam.getCamera() );
	
	// this pair of lines is the standard way to clear the screen in OpenGL
	gl::clear( Color( 0.9f, 0.9f, 0.9f ), true );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    // draw the cube
    gl::color(  ColorA(mRed, 0, 0, 0.90f)  );
	glPushMatrix();
	gl::drawCube(Vec3f(0.0f, 0.0f, 0.0f), Vec3f(50, 50, 50));
	glPopMatrix();
}



/**
 *  Cocoa UI methods
 */

- (void) setOSCoutput: (int) value
{
	console() << value << endl;
    
    [self propagate2OSC:value];
}



/**
 *  Custom OSC methods
 */

- (void) initOSC
{
    // initialize OSC stuff
	listener.setup(57120);
	host = "localhost";
	port = 7005;
	sender.setup(host, port);
}

- (void) receiveOSC
{
    while (listener.hasWaitingMessages()) {
		osc::Message message;
		listener.getNextMessage(&message);
		
		console() << "New message received" << std::endl;
		console() << "Address: " << message.getAddress() << std::endl;
		console() << "Num Arg: " << message.getNumArgs() << std::endl;
		for (int i = 0; i < message.getNumArgs(); i++) {
			console() << "-- Argument " << i << std::endl;
			console() << "---- type: " << message.getArgTypeName(i) << std::endl;
			if (message.getArgType(i) == osc::TYPE_INT32){
				try {
					console() << "------ value: "<< message.getArgAsInt32(i) << std::endl;
				}
				catch (...) {
					console() << "Exception reading argument as int32" << std::endl;
				}
				
			} else if (message.getArgType(i) == osc::TYPE_FLOAT){
				try {
                    mRed = message.getArgAsFloat(i);
					console() << "------ value: " << message.getArgAsFloat(i) << std::endl;
				}
				catch (...) {
					console() << "Exception reading argument as float" << std::endl;
				}
			} else if (message.getArgType(i) == osc::TYPE_STRING){
				try {
					console() << "------ value: " << message.getArgAsString(i).c_str() << std::endl;
				}
				catch (...) {
					console() << "Exception reading argument as string" << std::endl;
				}
			}
		}
	}
}
    
- (void) propagate2OSC: (int) value
    {
    // send mCubeSize to OSC port
	osc::Message message;
	message.addIntArg(value);
	message.setAddress("/cinder/osc/1");
	message.setRemoteEndpoint(host, port);
	sender.sendMessage(message);
}



/**
 *  Superclass events
 */

- (void)reshape
{
	[super reshape];
	
	CameraPersp cam;
	cam = mMayaCam.getCamera();
	cam.setAspectRatio( [self getWindowAspectRatio] );
	mMayaCam.setCurrentCam( cam );
}

- (void)mouseDown:(NSEvent*)theEvent
{
	[super mouseDown:(NSEvent *)theEvent];
	
	NSPoint curPoint = [theEvent locationInWindow];
	mMayaCam.mouseDown( Vec2i(curPoint.x, curPoint.y) );
	//console() << "MouseDown x : " << curPoint.x << ", y : " << curPoint.y << endl;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[super mouseDragged:(NSEvent *)theEvent];
	
	NSPoint curPoint = [theEvent locationInWindow];
	mMayaCam.mouseDrag( Vec2i(curPoint.x, -curPoint.y), true, false, false );
}

@end
