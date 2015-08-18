//
//  MyCinderGLDrawing.mm
//  CCGLDragnDropFiles example
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
    mDroppedFiles = 0;
}



#pragma mark - The superclass draw loop method

- (void) draw
{
	// use the camera 
	gl::setMatrices( mMayaCam.getCamera() );
	
	// this pair of lines is the standard way to clear the screen in OpenGL
	gl::clear( Color( 0.9f, 0.9f, 0.9f ), true );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
	// draw the grid
    gl::color(  Color(0, 0, 0)  );
	drawGrid(100.0f, 10.0f);

    // draw the cube
    gl::color(  ColorA(1, 0, 0, 0.90f)  );
	glPushMatrix();
    for (int i=0; i<mDroppedFiles; i++) {
        gl::drawCube(Vec3f(0.0f, 0.0f, 0.0f), Vec3f(mCubeSize, mCubeSize, mCubeSize));
        glTranslatef(0, 0, 60);
    }
	glPopMatrix();
}



#pragma mark - Custom drawing methods

void drawGrid(float size, float step)
{
	for(float i=-size;i<=size;i+=step) {
		gl::drawLine( Vec3f(i, 0.0f, -size), Vec3f(i, 0.0f, size) );
		gl::drawLine( Vec3f(-size, 0.0f, i), Vec3f(size, 0.0f, i) );
	}
}




#pragma mark - Cocoa UI methods

- (void)setCubeSize:(int)size
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

- (void)dragAndDropFiles:(NSArray *)filenames
{
	for (int i=0; i<[filenames count]; i++) {
		NSLog([filenames objectAtIndex:i]);
		NSString *filename = [filenames objectAtIndex:i];
        
        mDroppedFiles++;
        
		/*if ([filename hasSuffix:@".aif"] || [filename hasSuffix:@".wav"] || [filename hasSuffix:@".mp3"]) {
           // do something with a sound file 
		}
		else {
			NSBeep();
		}*/
	}	
}

@end
