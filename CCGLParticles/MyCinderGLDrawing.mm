//
//  MyCinderGLDrawing.mm
//  CCGLParticles example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#import "MyCinderGLDrawing.h"
#include "cinder/Rand.h"

@implementation MyCinderGLDrawing

/**
 *  The setup method
 */

- (void) setup
{
	[super setup];
	
	// setup our camera
	CameraPersp cam;
	/*cam.lookAt( Vec3f( -100, 10, 10 ), Vec3f::zero() );*/
	cam.setEyePoint( Vec3f(-30.0f, 20.0f, 10.0f) );
	cam.setCenterOfInterestPoint( Vec3f(0.0f, 0.0f, 0.0f) );
	cam.setPerspective( 60.0f, [self getWindowAspectRatio], 1.0f, 1000.0f );
	mMayaCam.setCurrentCam( cam );
	
	// set initial value
    mPAmount = 0;

    // Load texture
	mTexture = gl::Texture( loadImage( [self loadResource:RES_IMAGE] ) );
	mShader = gl::GlslProg( [self loadResource:RES_SHADER_VERT], [self loadResource:RES_SHADER_FRAG] );
	mTexture.bind();
	mShader.bind();
	mShader.uniform( "tex0", 0 );
    
    for (int i=0; i<100; i++) {
        float descriptors[12];
        descriptors[0] = Rand::randFloat(5.5f, 50.0f);
        descriptors[1] = Rand::randFloat(5.5f, 50.0f);
        descriptors[2] = Rand::randFloat(5.5f, 50.0f);
        descriptors[3] = Rand::randFloat(5.5f, 50.0f);
        descriptors[4] = Rand::randFloat(5.5f, 50.0f);
        descriptors[5] = Rand::randFloat(5.5f, 50.0f);
        descriptors[6] = Rand::randFloat(5.5f, 50.0f);
        descriptors[7] = Rand::randFloat(5.5f, 50.0f);
        descriptors[8] = Rand::randFloat(5.5f, 50.0f);
        descriptors[9] = Rand::randFloat(5.5f, 50.0f);
        descriptors[10] = Rand::randFloat(5.5f, 50.0f);
        descriptors[11] = Rand::randFloat(5.5f, 50.0f);
        mParticleController.addParticle( i, descriptors );
    }
}



/**
 *  The draw loop method
 */

- (void) draw
{
    // calculate elapsed time
	mTime = [self getElapsedSeconds];

	// use the camera 
	gl::setMatrices( mMayaCam.getCamera() );
	
	// this pair of lines is the standard way to clear the screen in OpenGL
	gl::clear( Color( 0, 0, 0 ), true );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
	/*// draw the grid
    gl::color(  Color(0.5f, 0.5f, 0.5f)  );
	drawGrid(100.0f, 10.0f);
    // draw the cube
    gl::color(  ColorA(1, 1, 1, 0.90f)  );
	glPushMatrix();
	gl::drawCube(Vec3f(0.0f, 0.0f, 0.0f), Vec3f(1, 1, 1));
	glPopMatrix();
    
	// bind the texture
	mTexture.bind();
    
	// bind the shader and tell it to use our texture
	mShader.bind();
	mShader.uniform("tex0", 0);*/
	
	// draw the particles
	mParticleController.draw();
    
	// unbind the shader and texture
	/*mShader.unbind();
	mTexture.unbind();*/
}



/**
 *  Cocoa UI methods
 */

- (void) setParticleAmount: (int) value
{
    mPAmount = value;
	console() << value << endl;
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
