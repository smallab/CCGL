//
//  MyCinderGLDrawing.mm
//  CCGLMesh2VBO example
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
	
    // Load the .obj file into a mesh
	ObjLoader loader( (DataSourceRef) [self loadResource:RES_CUBE_OBJ] );
	loader.load( &mMesh, true, true, true );
    console() << "TriMesh vertex count : " << mMesh.getNumVertices() << endl;

	// setup the parameters of the Vbo
	gl::VboMesh::Layout layout;
	layout.setStaticIndices();
	layout.setDynamicPositions();
	layout.setStaticTexCoords2d();
	mVboMesh = gl::VboMesh( mMesh, layout );
    console() << "VboMesh vertex count : " << mVboMesh.getNumVertices() << endl;
    console() << "VboMesh index count : " << mVboMesh.getNumIndices() << endl;
    
    // load the tex
	mTexture = gl::Texture( loadImage( [self loadResource:RES_IMAGE] ) );
    
	// set up the camera
	CameraPersp cam;
	cam.setEyePoint( Vec3f(5.0f, 10.0f, 20.0f) );
	cam.setCenterOfInterestPoint( Vec3f(0.0f, 2.5f, 0.0f) );
	cam.setPerspective( 60.0f, [self getWindowAspectRatio], 1.0f, 1000.0f );
	mMayaCam.setCurrentCam( cam );
	
	// set initial value
	mXFactor = 10;
}
    
    
/**
 *  The superclass draw loop method
 */

- (void) draw
{
    animateVertices([self getElapsedSeconds], mVboMesh, mMesh, mXFactor);

    gl::setMatrices( mMayaCam.getCamera() );
    
	// this pair of lines is the standard way to clear the screen in OpenGL
	gl::clear( Color( 0.15f, 0.15f, 0.15f ) );
    
	gl::scale( Vec3f( 10, 10, 10 ) );
	mTexture.enableAndBind();
	gl::draw( mVboMesh );
}



/**
 *  Custom drawing methods
 */

void animateVertices(float myTime, gl::VboMesh &vboMesh, TriMesh &mesh, int xFactor)
{
	const float timeFreq = 5.0f;
	const float xFreq = 7.0f * (xFactor+1)/10.0f;
	float offset = myTime * timeFreq;
    
    std::vector<ci::Vec3f> vecs = mesh.getVertices();
    
	// dynamically generate our new positions based on a simple sine wave
	gl::VboMesh::VertexIter iter = vboMesh.mapVertexBuffer();
	for( int i = 0; i < vboMesh.getNumVertices(); ++i ) {
        float height = sin( i / xFreq + offset ) / 5.0f;
        Vec3f v = vecs.at(i);
        iter.setPosition( Vec3f( v.x+height, v.y, v.z ) );
        ++iter;
	}
}



/**
 *  Cocoa UI methods
 */

- (void) setXFactor: (int) factor
{
	mXFactor = factor;
	console() << factor << endl;
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

- (void)mouseMoved:(NSEvent *)theEvent
{
	[super mouseMoved:(NSEvent *)theEvent];
	
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDown:(NSEvent *)theEvent];
	
	NSPoint curPoint = [theEvent locationInWindow];
	mMayaCam.mouseDown( Vec2i(curPoint.x, curPoint.y) );
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[super mouseDragged:(NSEvent *)theEvent];
	
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mMayaCam.mouseDrag( Vec2i(curPoint.x, -curPoint.y), true, false, false );
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:(NSEvent *)theEvent];
}

@end
