//
//  MyCinderGLDrawing.mm
//  CCGLObj2Mesh example
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
	
    // Setup the mouse-controlled camera
	CameraPersp cam;
	cam.setPerspective( 10.0f, [self getWindowAspectRatio], 1.0f, 1000.0f );
	mMayaCam.setCurrentCam( cam );
    
    // Load the .obj file into a mesh
	ObjLoader loader( (DataSourceRef) [self loadResource:RES_WARP_OBJ] ); // RES_CUBE_OBJ
	loader.load( &mMesh );
    // Optionally pass the mesh to a VBO
	//mVBO = gl::VboMesh( mMesh );
	
	mTexture = gl::Texture( loadImage( [self loadResource:RES_IMAGE] ) );
	mShader = gl::GlslProg( [self loadResource:RES_SHADER_VERT], [self loadResource:RES_SHADER_FRAG] );
    
	mTexture.bind();
	mShader.bind();
	mShader.uniform( "tex0", 0 );
}




/**
 *  The superclass draw loop method
 */

- (void) draw
{
	gl::enableDepthWrite();
	gl::enableDepthRead();
	
	gl::clear( Color( 0.0f, 0.1f, 0.2f ) );
	glDisable( GL_CULL_FACE );
    
	gl::setMatrices( mMayaCam.getCamera() );
    
    /*	Sphere boundingSphere = Sphere::calculateBoundingSphere( mMesh.getVertices() );
     glColor3f( 1.0f, 1.0f, 1.0f );
     gl::disableDepthWrite();
     mTexture->disable();
     mShader.unbind();
     gl::draw( boundingSphere, 30 );
     gl::enableDepthWrite();
     */
    
	mShader.bind();
	gl::pushMatrices();
    // Draw the mesh
    gl::draw( mMesh );
    // Optionally draw using VBO straight from the graphics card
    //gl::draw( mVBO );
	gl::popMatrices();
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
