//
//  MyOtherCinderGLDrawing.mm
//  CCGLMultipleDrawings example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#import "MyOtherCinderGLDrawing.h"
#import "Resources.h"


@implementation MyOtherCinderGLDrawing

#pragma mark - The setup method

- (void)setup
{
	[super setup];
	
	// setup our camera
	CameraPersp cam;
	cam.setEyePoint( Vec3f(-100.0f, 20.0f, 60.0f) );
	cam.setCenterOfInterestPoint( Vec3f(0.0f, 0.0f, 0.0f) );
	cam.setPerspective( 60.0f, [self getWindowAspectRatio], 1.0f, 1000.0f );
	mMayaCam.setCurrentCam( cam );
    
    // Load texture
	mTexture = gl::Texture( loadImage( [self loadResource:RES_IMAGE_SMALLAB] ) );
	
	// set initial value
	mCubeSize = 50;
}



#pragma mark - The draw loop method

- (void)draw
{
	// use the camera 
	gl::setMatrices( mMayaCam.getCamera() );
	
	// this pair of lines is the standard way to clear the screen in OpenGL
	gl::clear( Color( 0.9f, 0.9f, 0.9f ), true );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
	// draw the grid
//    gl::color(  Color(0, 0, 0)  );
	//drawGrid(100.0f, 10.0f);
    
    // draw the cube
	mTexture.enableAndBind();
    gl::color(  ColorA(1, 1, 1, 0.50f)  );
	glPushMatrix();
	gl::drawColorCube(Vec3f(0.0f, 0.0f, 0.0f), Vec3f(mCubeSize, mCubeSize, mCubeSize));
	glPopMatrix();
}




#pragma mark - Cocoa UI methods

- (void) setCubeSize:(int)size
{
	mCubeSize = size;
	console() << size << endl;
}



#pragma mark - Superclass events

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
