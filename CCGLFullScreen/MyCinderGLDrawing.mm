//
//  MyCinderGLDrawing.mm
//  CCGLFullScreen example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
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
	
	// setup the camera
	cam.lookAt( Vec3f(-100.0f, 10.0f, 10.0f), Vec3f::zero() );
	cam.setPerspective( 60.0f, [self getWindowAspectRatio], 1.0f, 1000.0f );
}



/**
 *  The superclass draw loop method
 */

- (void) draw
{
    // use the camera
    gl::setMatrices( cam );
    
	// this pair of lines is the standard way to clear the screen in OpenGL
	gl::clear( Color( 0.9f, 0.9f, 0.9f ), true );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    // draw a rotating cube
	glPushMatrix();
    glRotatef(10.0f * frameCount, 0.0f, 1.0f, 0.0f);
	gl::drawColorCube( Vec3f(0.0f, 0.0f, 0.0f), Vec3f(50.0f, 50.0f, 50.0f) );
	glPopMatrix();
}



/**
 *  Superclass events
 */

- (void)reshape
{
	[super reshape];

	// update the camera after resizing
	cam.setPerspective( 60.0f, [self getWindowAspectRatio], 1.0f, 1000.0f );
}

- (void)keyDown:(NSEvent*)theEvent
{
	[super keyDown:(NSEvent *)theEvent];
    
	if ([theEvent keyCode] == 53 && [self isInFullScreenMode] == YES) // 53 = ESC key
        [self exitFullScreenModeWithOptions:nil];
}

@end
