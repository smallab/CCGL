//
//  MyCinderGLDrawing.mm
//  CCGLLights example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#import "MyCinderGLDrawing.h"

@implementation MyCinderGLDrawing

#pragma mark - The superclass setup method

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
	mCubeSize = 50;
    mMatSpec = 50;
}



#pragma mark - The superclass draw loop method

- (void) draw
{
    // use some lights
    [self someLights];
    
	// use the camera 
	gl::setMatrices( mMayaCam.getCamera() );
	
	// this pair of lines is the standard way to clear the screen in OpenGL
	gl::clear( Color( 0.9f, 0.9f, 0.9f ), true );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
	// draw the grid
	drawGrid(100.0f, 10.0f);

    // draw the cube
	glPushMatrix();
    gl::drawSphere(Vec3f::zero(), (int) (mCubeSize/2), 128);
    gl::drawStrokedCube(Vec3f::zero(), Vec3f(mCubeSize, mCubeSize, mCubeSize));
	glPopMatrix();
}



#pragma mark - Custom drawing methods

- (void) someLights
{
    // enable lights
    glEnable( GL_LIGHTING );
    
    // create a first light
    glEnable( GL_LIGHT0 );
    //define components
	GLfloat lightPosition0[]    = { -10.0f, 0.5f, 0.0f, 0.0000001f };
	GLfloat light_diffuse0[]	= { 0.9, 0.0, 0.0, 1.0 };
	GLfloat light_specular0[]	= { 1.0, 1.0, 1.0, 1.0 };
    //setup the light
	glLightfv( GL_LIGHT0, GL_POSITION, lightPosition0 );
	glLightfv( GL_LIGHT0, GL_DIFFUSE,  light_diffuse0 );
	glLightfv( GL_LIGHT0, GL_SPECULAR, light_specular0 );
    
    // create a second light
    glEnable( GL_LIGHT1 );
    // define components
	GLfloat lightPosition1[]     = { 1.0f, 1.0f, 0.0f, 0.0000001f };
	GLfloat light_diffuse1[]		= { 0.3, 0.5, 0.8, 1.0 };
	GLfloat light_specular1[]	= { 1.0, 1.0, 1.0, 1.0 };
	// setup the light
	glLightfv( GL_LIGHT1, GL_POSITION,  lightPosition1 );
	glLightfv( GL_LIGHT1, GL_DIFFUSE,   light_diffuse1 );
	glLightfv( GL_LIGHT1, GL_SPECULAR,  light_specular1 );
    
    // create a third light
    glEnable( GL_LIGHT2 );
    // define components
	GLfloat lightPosition2[]     = { 0.0f, -10.0f, -20.0f, 0.0000001f };
	GLfloat light_diffuse2[]		= { 0.3, 0.8, 0.5, 1.0 };
	GLfloat light_specular2[]	= { 1.0, 1.0, 1.0, 1.0 };
	// setup the light
	glLightfv( GL_LIGHT2, GL_POSITION,  lightPosition2 );
	glLightfv( GL_LIGHT2, GL_DIFFUSE,   light_diffuse2 );
	glLightfv( GL_LIGHT2, GL_SPECULAR,  light_specular2 );

    // setup the material
    float matSpec = mMatSpec/100.0f; // using the value chosen by the user with the "Material specularity" slider
	GLfloat mat_specular[]		= { matSpec, matSpec, matSpec, 1.0 };
	GLfloat mat_emission[]		= { 0.0, 0.0, 0.0, 0.0 };
	GLfloat mat_shininess[]		= { 128.0 };
	glMaterialfv( GL_FRONT, GL_DIFFUSE,	ColorA( 0.75f, 0.75f, 0.75f, 1.0f ) );
	glMaterialfv( GL_FRONT, GL_SPECULAR, mat_specular );
	glMaterialfv( GL_FRONT, GL_EMISSION, mat_emission );
	glMaterialfv( GL_FRONT, GL_SHININESS, mat_shininess );
}

void drawGrid(float size, float step)
{
	for(float i=-size;i<=size;i+=step) {
		gl::drawLine( Vec3f(i, 0.0f, -size), Vec3f(i, 0.0f, size) );
		gl::drawLine( Vec3f(-size, 0.0f, i), Vec3f(size, 0.0f, i) );
	}
}



#pragma mark - Cocoa UI methods

- (void) setCubeSize: (int) size
{
	mCubeSize = size;
	console() << size << endl;
}

- (void) setMatSpec: (int) matSpec
{
	mMatSpec = matSpec;
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
