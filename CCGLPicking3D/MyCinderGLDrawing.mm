//
//  MyController.mm
//  CCGLPicking3D example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//
//  This example is based on Paul Houx's great Picking3D sample included in Cinder's
//  distribution
//  

#import "MyCinderGLDrawing.h"

@implementation MyCinderGLDrawing

/**
 *  The superclass setup method
 */

- (void) setup
{
	[super setup];
	
	// initialize stuff
    openHandCursor();
	mTime = [self getElapsedSeconds];
	mTransform.setToIdentity();
    
	// load and compile the shader
	//  (note: a shader is not required, but gives a much better visual appearance.
	//	See for yourself by disabling the 'mShader.bind()' call in the draw method.)
	mShader = gl::GlslProg( [self loadResource:RES_SHADER_VERT], [self loadResource:RES_SHADER_FRAG] );
    
	// load the texture
	//  (note: enable mip-mapping by default)
	gl::Texture::Format format;
	format.enableMipmapping(true);			
	ImageSourceRef img = loadImage( [self loadResource:RES_DUCKY_TEX] );
	if(img) mTexture = gl::Texture( img, format );
    
    
	// load the mesh 
	//  (note: the mesh was created from an OBJ file
	//  using the ObjLoader class. The data was then saved using the
	//  TriMesh::write() method. Reading binary files is much quicker.)
	mMesh.read( [self loadResource:RES_DUCKY_MESH] );
    
	// set up the camera
	CameraPersp cam;
	cam.setEyePoint( Vec3f(5.0f, 10.0f, 10.0f) );
	cam.setCenterOfInterestPoint( Vec3f(0.0f, 2.5f, 0.0f) );
	cam.setPerspective( 60.0f, [self getWindowAspectRatio], 1.0f, 1000.0f );
	mMayaCam.setCurrentCam( cam );
}


/**
 *  The superclass draw loop method
 */

- (void) draw
{
    [self animateDuck];
    
	// gray background
	gl::clear( Colorf(0.5f, 0.5f, 0.5f) );
    
	// set up the camera 
	gl::pushMatrices();
	gl::setMatrices( mMayaCam.getCamera() );
    
	// enable the depth buffer (after all, we are doing 3D)
	gl::enableDepthRead();
	gl::enableDepthWrite();
    
	// draw the grid on the floor
    gl::color( Colorf(0.2f, 0.2f, 0.2f) );
	drawGrid(100.0f, 10.0f);
    
	// bind the texture
	mTexture.bind();
    
	// bind the shader and tell it to use our texture
	mShader.bind();
	mShader.uniform("tex0", 0);
    
	// draw the mesh 
	//  (note: reset current color to white so the actual texture colors show up)
	gl::color( Color::white() );
	//  (note: apply transformations to the model)
	gl::pushModelView();
    gl::multModelView( mTransform );
    gl::draw( mMesh );
	gl::popModelView();
    
	// unbind the shader and texture
	mShader.unbind();
	mTexture.unbind();
    
	// perform 3D picking now, so we can draw the intersection as a sphere
	Vec3f pickedPoint, pickedNormal;
	if ( [self performPickingWith:&pickedPoint And:&pickedNormal] ) {
		gl::color( ColorAf(0.0f, 0.0f, 0.0f, 0.5f) );
		// draw an arrow to the picked point along its normal
		gl::drawVector( pickedPoint, pickedPoint + pickedNormal );
	}
    
	gl::popMatrices();
}




/**
 *  Custom drawing methods
 */

void drawGrid(float size, float step)
{
	for(float i=-size;i<=size;i+=step) {
		gl::drawLine( Vec3f(i, 0.0f, -size), Vec3f(i, 0.0f, size) );
		gl::drawLine( Vec3f(-size, 0.0f, i), Vec3f(size, 0.0f, i) );
	}
}

- (void) animateDuck
{
	// calculate elapsed time
	mTime = [self getElapsedSeconds];
    
	// animate our little ducky
	mTransform.setToIdentity();
	mTransform.rotate( Vec3f::xAxis(), sinf( (float) mTime * 3.0f ) * 0.08f );
	mTransform.rotate( Vec3f::yAxis(), (float) mTime * 0.1f );
	mTransform.rotate( Vec3f::zAxis(), sinf( (float) mTime * 4.3f ) * 0.09f );
}

- (bool) performPickingWith:(Vec3f *) pickedPoint And:(Vec3f *) pickedNormal
{
	// get our camera 
	CameraPersp cam = mMayaCam.getCamera();
    
	// generate a ray from the camera into our world
	float u = mMousePos.x / (float) [self getWindowWidth];
	float v = mMousePos.y / (float) [self getWindowHeight];
	// because OpenGL and Cinder use a coordinate system
	// where (0, 0) is in the LOWERleft corner, we have to flip the v-coordinate
    //THAT IS NOT TRUE HERE THOUGH...
	//Ray ray = cam.generateRay(u , 1.0f - v, cam.getAspectRatio() );
    Ray ray = cam.generateRay(u , v, cam.getAspectRatio() );
    
	// get the bounding box of the model, for fast intersection testing
	AxisAlignedBox3f objectBounds = mMesh.calcBoundingBox();
    
	// draw this untransformed box in yellow
	gl::color( Color(1, 1, 0) );
	gl::drawStrokedCube(objectBounds);
    
	// the coordinates of the bounding box are in object space, not world space,
	// so if the model was translated, rotated or scaled, the bounding box would not
	// reflect that.
	AxisAlignedBox3f worldBounds = mMesh.calcBoundingBox(mTransform);
    
	// draw this transformed box in cyan
	gl::color( Color(0, 1, 1) );
	gl::drawStrokedCube(worldBounds);
    
	// set initial distance to something far, far away
	float result = 1.0e6f;
    
	// fast detection first - test against the bounding box itself
	if( ! worldBounds.intersects(ray) )
		return false;
    
	// traverse triangle list and find the picked triangle
	size_t polycount = mMesh.getNumTriangles();
	float distance = 0.0f;
	for(size_t i=0;i<polycount;++i)
	{
		Vec3f v0, v1, v2;
		// get a single triangle from the mesh
		mMesh.getTriangleVertices(i, &v0, &v1, &v2);
        
		// transform triangle to world space
		v0 = mTransform.transformPointAffine(v0);
		v1 = mTransform.transformPointAffine(v1);
		v2 = mTransform.transformPointAffine(v2);
        
		// test to see if the ray intersects with this triangle
		if( ray.calcTriangleIntersection(v0, v1, v2, &distance) ) {
			// set our result to this if its closer than any intersection we've had so far
			if( distance < result ) {
				result = distance;
				// assuming this is the closest triangle, we'll set our normal
				// while we've got all the points handy
				*pickedNormal = ( v1 - v0 ).cross( v2 - v0 ).normalized();
			}
		}
	}
    
	// did we have a hit?
	if( distance > 0 ) {
		*pickedPoint = ray.calcPosition( result );
		return true;
	}
	else
		return false;
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

	// keep track of the mouse
	mMousePos = Vec2i(curPoint.x, curPoint.y);
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[super mouseDown:(NSEvent *)theEvent];
	
	NSPoint curPoint = [theEvent locationInWindow];
	mMayaCam.mouseDown( Vec2i(curPoint.x, curPoint.y) );

    closedHandCursor();
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	[super mouseDragged:(NSEvent *)theEvent];
	
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mMayaCam.mouseDrag( Vec2i(curPoint.x, -curPoint.y), true, false, false );
    
	// keep track of the mouse
	mMousePos = Vec2i(curPoint.x, curPoint.y);
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:(NSEvent *)theEvent];
    
    openHandCursor();
}

@end
