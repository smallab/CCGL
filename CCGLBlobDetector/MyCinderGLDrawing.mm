//
//  MyCinderGLDrawing.mm
//  CCGLBlobDetection example
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
	[self resetCamera];
	
	// set initial values
    mWidth = 640;
    mHeight = 480;
    mLevels = 30;
    m3D = 0;
    mDrawCapture = true;
    
    // launch capture
	try {
		mCap = Capture( mWidth, mHeight );
		mCap.start();
	}
	catch( ... ) {
		console() << "Failed to initialize capture" << std::endl;
	}
}



/**
 *  The superclass draw loop method
 */

- (void) draw
{
	// use the camera 
	gl::setMatrices( mMayaCam.getCamera() );
    
    // draw the capture
    if (mCap && mCap.checkNewFrame())
    {
        // Make greyscale copy of input
        cv::Mat input( toOcv( mCap.getSurface() ) );
        cv::Mat gray;
        //make sure you only get the gray
        cv::cvtColor( input, gray, CV_RGB2GRAY );
        
        // Blur
        cv::Mat blur(cv::Size(mWidth, mHeight), CV_8U);
        cv::blur(gray, blur, cv::Size(3, 3));
        
        // Contours lists
        mCvContours.clear();
        for (int i=0; i<mLevels; i++) {
            // Threshold
            cv::Mat threshold(cv::Size(mWidth, mHeight), CV_8U);
            cv::threshold(blur, threshold, (int) i*(254.0f/mLevels), (int) i*(254.0f/mLevels), CV_8U);
            std::vector< std::vector<cv::Point> > contours;
            cv::findContours(threshold, contours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
            mCvContours.push_back(contours);
        }
        
        // Get processed image to gl::draw()
        if (mDrawCapture)
            mTexture = gl::Texture(fromOcv(input));
    }
    
    // clear out the window with black
    gl::clear( Color( 0, 0, 0 ) );
    gl::color( Color( 1.0f, 1.0f, 1.0f ) );
    
    // turn upside down and center the matrix around the elements
    glPushMatrix();
    glRotatef(180, 0.0f, 0.0f, 1.0f);
    glTranslatef( Vec3f( -mWidth/2.0f, -mHeight/2.0f, 0.0f ) );
    
    // draw the capture
    if( mTexture && mDrawCapture ) {
        glTranslatef( Vec3f( 0.0f, 0.0f, -1.0f ) );
        gl::draw( mTexture );
        glTranslatef( Vec3f( 0.0f, 0.0f, 1.0f ) );
    }
    
    // show the contours
    for (int i=0; i<mCvContours.size(); i++) {
        // apply 3D effect to blobs if any of both
        glPushMatrix();
        glTranslatef( Vec3f( 0.0f, 0.0f, m3D*(i) ) );

        // calculate colors
        float u = (float) i/(float) mLevels;
        float d = 1 - u;
        gl::color( Color( d, 0.0f, u ) );
        
        // write blobs as GL line loops
        std::vector< std::vector<cv::Point> > contours = mCvContours.at(i);
        for (vector< vector<cv::Point> >::iterator iter = contours.begin(); iter!=contours.end(); ++iter) {
            glBegin( GL_LINE_LOOP );
            for( vector<cv::Point>::iterator edge = iter->begin(); edge != iter->end(); ++edge ) {
                //gl::color( Color( CM_HSV, 0.2f, 0.3f, Rand::randFloat(1.0f) ) );
                gl::vertex( fromOcv( *edge ) );
            }
            glEnd();
        }

        glPopMatrix();
    }
    
    glPopMatrix();
}




/**
 *  Cocoa UI methods
 */

- (void) setBlobLevels:(int)levels
{
	mLevels = levels;
}

- (void) set3dEffect:(int)effect
{
	m3D = effect;
}

- (void)resetCamera
{
	CameraPersp cam;
	cam.setEyePoint( Vec3f(0.0f, 0.0f, 500.0f) );
	cam.setCenterOfInterestPoint( Vec3f::zero() );
	cam.setPerspective( 60.0f, [self getWindowAspectRatio], 1.0f, 10000.0f );
	mMayaCam.setCurrentCam( cam );
}
- (void)showFeed:(bool)show
{
    mDrawCapture = show;
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

- (void)keyDown:(NSEvent*)theEvent
{
	[super keyDown:(NSEvent *)theEvent];
    
	if ([theEvent keyCode] == 53 && [self isInFullScreenMode] == YES)
        [self exitFullScreenModeWithOptions:nil];
}

@end
