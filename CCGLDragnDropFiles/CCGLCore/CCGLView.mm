//
//  CCGLView.h
//  Core class of the CocoaCinderGL wrapper.
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//
//  Latest revision on 11/21/13.
//
//
//  The Cinder source code is used under the following terms:
//
//
//  Copyright (c) 2010, The Barbarian Group
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that
//  the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and
//  the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
//  the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//   ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "CCGLView.h"

@implementation CCGLView

/**
 *	Overriding NSView's initWithFrame: to specify our pixel format
 *
 *	Note: initWithFrame is called only if a "Custom View" is used in Interface Builder
 *	and the custom class is a subclass of NSView. For more information on resource loading
 *	see: developer.apple.com (ADC Home > Documentation > Cocoa > Resource Management > Loading Resources)
 */

- (id) initWithFrame: (NSRect) frame
{
	const int sAntiAliasingSamples[] = { 0, 2, 4, 6, 8, 16, 32 };
	NSOpenGLPixelFormatAttribute attribs [] = {
		NSOpenGLPFAWindow,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)24,
		NSOpenGLPFASampleBuffers, (NSOpenGLPixelFormatAttribute)1,
		NSOpenGLPFASamples, (NSOpenGLPixelFormatAttribute)sAntiAliasingSamples[32],
		NSOpenGLPFANoRecovery,
		(NSOpenGLPixelFormatAttribute)0
	};
	NSOpenGLPixelFormat* fmt = [[NSOpenGLPixelFormat alloc] initWithAttributes: attribs];
	
	if (!fmt)
		NSLog(@"No OpenGL pixel format");
	else {
		// init stuff here
        frameRate = 30;
	}
	
	return self = [super initWithFrame:frame pixelFormat: fmt ];
}



/**
 *	Overriding the NSView's awakeFromNib: and building animation timer
 */

- (void) awakeFromNib
{
    [[self window] setAcceptsMouseMovedEvents:YES];
    
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
	frameCount = 0;
    float frameLength = 1/frameRate;
	drawTimer = /*[*/ [NSTimer scheduledTimerWithTimeInterval:frameLength target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    startTime = ::CFAbsoluteTimeGetCurrent();
}

- (void) timer: (NSTimer *) timer
{
	frameCount ++;
	[self setNeedsDisplay:YES];
}



/**
 *	Overriding the NSView's drawRect: to draw our GL content
 */

- (void) drawRect: (NSRect) rect
{
	//[self update];
    
	if (!appSetupCalled) {
		[self setup];
		return;
	}
	
	[[self openGLContext] makeCurrentContext];
	GLint swapInterval = 1;
	[[self openGLContext] setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
    
	[self draw];
	
	[[self openGLContext] flushBuffer];
}



/**
 *	Preparing to draw
 */

- (void) setup
{
	[self glView];
	[self glParams];
	appSetupCalled = true;
}

/**
 *	Convenience camera method to be used in setup (or on reshape, etc.)
 */

- (void) glView
{
	glViewport( 0, 0, [self frame].size.width, [self frame].size.height );
	CameraPersp cam( [self frame].size.width, [self frame].size.height, 60.0f );
	
	glMatrixMode( GL_PROJECTION );
	glLoadMatrixf( cam.getProjectionMatrix().m );
	
	glMatrixMode( GL_MODELVIEW );
	glLoadMatrixf( cam.getModelViewMatrix().m );
	glScalef( 1.0f, -1.0f, 1.0f );           // invert Y axis so increasing Y goes down.
	glTranslatef( 0.0f, (float)-[self frame].size.height, 0.0f );       // shift origin up to upper-left corner.
}

/**
 *	Some default GL parameters to be used in setup
 */

- (void) glParams
{
	gl::enableDepthWrite();
	gl::enableDepthRead();
	gl::enableAlphaBlending();
	glDisable( GL_TEXTURE_2D );
    glShadeModel(GL_SMOOTH);
}



/**
 *  Actual drawing with a default scene clearing
 */

- (void) draw
{
	// this pair of lines is the standard way to clear the screen in OpenGL
	gl::clear( Color( 0.5f, 0.5f, 0.5f ), true );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
}



/**
 *  Cocoa'd general utils extracted from Cinder
 */

- (double) getElapsedSeconds
{
    return ::CFAbsoluteTimeGetCurrent() - startTime;
}

- (int) getWindowWidth
{
	NSRect bounds = [self bounds];
	return bounds.size.width; // should better use [self frame].size.height ?
}

- (int) getWindowHeight
{
	NSRect bounds = [self bounds];
	return bounds.size.height; // should better use [self frame].size.height ?
}

- (Area) getWindowBounds
{
    return Area( 0, 0, [self getWindowWidth], [self getWindowHeight] );
}

- (Surface)	copyWindowSurface
{
	return [self copyWindowSurface:[self getWindowBounds]];
}

- (Surface)	copyWindowSurface:(Area) area
{
	Area clippedArea = area.getClipBy( [self getWindowBounds] );
    
	Surface s( area.getWidth(), area.getHeight(), false );
	glFlush(); // there is some disagreement about whether this is necessary, but ideally performance-conscious users will use FBOs anyway
	GLint oldPackAlignment;
	glGetIntegerv( GL_PACK_ALIGNMENT, &oldPackAlignment );
	glPixelStorei( GL_PACK_ALIGNMENT, 1 );
	glReadPixels( area.x1, [self getWindowHeight] - area.y2, area.getWidth(), area.getHeight(), GL_RGB, GL_UNSIGNED_BYTE, s.getData() );
	glPixelStorei( GL_PACK_ALIGNMENT, oldPackAlignment );
	ip::flipVertical( &s );
	return s;
}

- (float) getWindowAspectRatio
{
	return [self getWindowWidth] / (float) [self getWindowHeight];
}

- (bool) withinDrawingBoundsX:(int)x Y:(int)y
{
    return (x < [self getWindowWidth] &&
            x > 0 &&
            y < [self getWindowHeight] &&
            y > 0);
}



/**
 *	Events
 */

- (BOOL) acceptsFirstResponder { return YES; }

- (void) update     // NSView's own update method
{
    [super update];
}

- (void)reshape		// scrolled, moved or resized
{
    [super setNeedsDisplay: YES];
    [[self openGLContext] update];
	
	glViewport( 0, 0, [self frame].size.width, [self frame].size.height ); // handling the zoom
}

- (int)prepMouseEventModifiers:(NSEvent *)evt
{
	unsigned int result = 0;
	if( [evt modifierFlags] & NSControlKeyMask ) result |= cinder::app::MouseEvent::CTRL_DOWN;
	if( [evt modifierFlags] & NSShiftKeyMask ) result |= cinder::app::MouseEvent::SHIFT_DOWN;
	if( [evt modifierFlags] & NSAlternateKeyMask ) result |= cinder::app::MouseEvent::ALT_DOWN;
	if( [evt modifierFlags] & NSCommandKeyMask ) result |= cinder::app::MouseEvent::META_DOWN;
	
	return result;
}

- (int)prepKeyEventModifiers:(NSEvent *)evt
{
	unsigned int result = 0;
	
	if( [evt modifierFlags] & NSShiftKeyMask ) result |= cinder::app::KeyEvent::SHIFT_DOWN;
	if( [evt modifierFlags] & NSAlternateKeyMask ) result |= cinder::app::KeyEvent::ALT_DOWN;
	if( [evt modifierFlags] & NSCommandKeyMask ) result |= cinder::app::KeyEvent::META_DOWN;
	if( [evt modifierFlags] & NSControlKeyMask ) result |= cinder::app::KeyEvent::CTRL_DOWN;
	
	return result;
}

- (void)keyDown:(NSEvent*)theEvent
{
	char c		= [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	int code	= [theEvent keyCode];
	int mods	= [self prepKeyEventModifiers:theEvent];
	
    if (mods == 8)
        mKeyShiftDown = true;
    else
        mKeyShiftDown = false;
    
	//cinder::app::KeyEvent k = cinder::app::KeyEvent (cinder::app::KeyEvent::translateNativeKeyCode( code ), (char)c, mods, code);
	//app->privateKeyDown__( k );
}

- (void)keyUp:(NSEvent*)theEvent
{
	char c		= [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	int code	= [theEvent keyCode];
	int mods	= [self prepKeyEventModifiers:theEvent];
	
    mKeyShiftDown = false;
	
	//app->privateKeyUp__( cinder::app::KeyEvent (cinder::app::KeyEvent::translateNativeKeyCode( code ), (char)c, mods, code) );
}

- (void)mouseDown:(NSEvent*)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
    if (mods == 8)
        mMouseShiftDown = true;
    else
        mMouseShiftDown = false;
    
	mods |= cinder::app::MouseEvent::LEFT_DOWN;
 	//app->privateMouseDown__( cinder::app::MouseEvent( cinder::app::MouseEvent::LEFT_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
    if (mods == 8)
        mRightMouseShiftDown = true;
    else
        mRightMouseShiftDown = false;
	
	mods |= cinder::app::MouseEvent::RIGHT_DOWN;
 	//app->privateMouseDown__( cinder::app::MouseEvent( cinder::app::MouseEvent::RIGHT_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
	mods |= cinder::app::MouseEvent::MIDDLE_DOWN;
 	//app->privateMouseDown__( cinder::app::MouseEvent( cinder::app::MouseEvent::MIDDLE_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)mouseUp:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
    mMouseShiftDown = false;
    
	mods |= cinder::app::MouseEvent::LEFT_DOWN;
	//app->privateMouseUp__( cinder::app::MouseEvent( cinder::app::MouseEvent::LEFT_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
    mRightMouseShiftDown = false;
	
	mods |= cinder::app::MouseEvent::RIGHT_DOWN;
	//app->privateMouseUp__( cinder::app::MouseEvent( cinder::app::MouseEvent::RIGHT_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
	mods |= cinder::app::MouseEvent::MIDDLE_DOWN;
	//app->privateMouseUp__( cinder::app::MouseEvent( cinder::app::MouseEvent::MIDDLE_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
	//app->privateMouseMove__( cinder::app::MouseEvent( 0, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
	mods |= cinder::app::MouseEvent::RIGHT_DOWN;
	//app->privateMouseDrag__( cinder::app::MouseEvent( cinder::app::MouseEvent::RIGHT_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
	
	mods |= cinder::app::MouseEvent::MIDDLE_DOWN;
	//app->privateMouseDrag__( cinder::app::MouseEvent( cinder::app::MouseEvent::MIDDLE_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
    
	//console() << "MouseDragged x : " << curPoint.x << ", y : " << curPoint.y << endl;
	
	mods |= cinder::app::MouseEvent::LEFT_DOWN;
	//app->privateMouseDrag__( cinder::app::MouseEvent( cinder::app::MouseEvent::LEFT_DOWN, curPoint.x, y, mods, 0.0f, [theEvent modifierFlags] ) );
}

- (void)scrollWheel:(NSEvent *)theEvent
{
	float wheelDelta		= [theEvent deltaX] + [theEvent deltaY];
	NSPoint curPoint		= [theEvent locationInWindow];
	//int y					= app->getWindowHeight() - curPoint.y;
	int mods				= [self prepMouseEventModifiers:theEvent];
    
	//console() << "MouseWheel x : " << curPoint.x << ", y : " << curPoint.y << ", wheeling : " << wheelDelta << endl;
    
	//app->privateMouseWheel__( cinder::app::MouseEvent( 0, curPoint.x, y, mods, wheelDelta / 4.0f, [theEvent modifierFlags] ) );
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
		NSLog(@"drag entered");
		return NSDragOperationCopy;
	}
	return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	return [self draggingEntered:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
		NSLog(@"drop performed");
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		[self dragAndDropFiles:filenames];
		return YES;
	}
	return NO;
}

- (void)dragAndDropFiles:(NSArray *)filenames
{
	for (int i=0; i<[filenames count]; i++) {
		NSLog([filenames objectAtIndex:i]);
		NSString *filename = [filenames objectAtIndex:i];
		if ([filename hasSuffix:@".gif"] || [filename hasSuffix:@".jpg"] || [filename hasSuffix:@".jpeg"] || [filename hasSuffix:@".png"]) {
            // do something with an image file
        }
        else {
            // NSBeep();
        }
	}
}



/**
 *  Cursor utils
 */

void arrowCursor()
{
    [[NSCursor arrowCursor] push];
}

void openHandCursor()
{
    [[NSCursor openHandCursor] push];
}

void closedHandCursor()
{
    [[NSCursor closedHandCursor] push];
}

void showCursor()
{
    [NSCursor unhide];
}

void hideCursor()
{
    [NSCursor hide];
}



/**
 *  Cinder's cout alias
 */

ostream& console()
{
	return cout;
}



/**
 *  Cinder's resource handling gone slightly or very Cocoa
 */

ResourceLoadExc::ResourceLoadExc( const string &macPath )
{
	sprintf( mMessage, "Failed to load resource: %s", macPath.c_str() );
}

- (DataSourcePathRef) loadResource:(string) macPath
{
	string resourcePath = [self getResourcePath:macPath];
	if( resourcePath.empty() )
		throw ResourceLoadExc( macPath );
	else
		return DataSourcePath::create( resourcePath );
}

- (string) getResourcePath:(string) rsrcRelativePath
{
	string path = getPathDirectory( rsrcRelativePath );
	string fileName = getPathFileName( rsrcRelativePath );
	
	if( fileName.empty() )
		return string();
	
	NSString *pathNS = 0;
	if( ( ! path.empty() ) && ( path != rsrcRelativePath ) )
		pathNS = [NSString stringWithUTF8String:path.c_str()];
	
	NSString *resultPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:fileName.c_str()] ofType:nil inDirectory:pathNS];
	if( ! resultPath )
		return string();
	
	return string([resultPath cStringUsingEncoding:NSUTF8StringEncoding]);
}

string getOpenFilePath( const string &initialPath, vector<string> extensions )
{
	/*bool wasFullScreen = isFullScreen();
     setFullScreen( false );*/
	
	NSOpenPanel *cinderOpen = [NSOpenPanel openPanel];
	[cinderOpen setCanChooseFiles:YES];
	[cinderOpen setCanChooseDirectories:NO];
	[cinderOpen setAllowsMultipleSelection:NO];
	
	NSMutableArray *typesArray = nil;
	if( ! extensions.empty() ) {
		typesArray = [NSMutableArray arrayWithCapacity:extensions.size()];
		for( vector<string>::const_iterator extIt = extensions.begin(); extIt != extensions.end(); ++extIt )
			[typesArray addObject:[NSString stringWithUTF8String:extIt->c_str()]];
	}
	
	NSString *directory = initialPath.empty() ? nil : [[NSString stringWithUTF8String:initialPath.c_str()] stringByExpandingTildeInPath];
	int resultCode = [cinderOpen runModalForDirectory:directory file:nil types:typesArray];
	
	/*setFullScreen( wasFullScreen );
     restoreWindowContext();*/
	
	if( resultCode == NSOKButton ) {
		NSString *result = [[cinderOpen filenames] objectAtIndex:0];
		return string( [result UTF8String] );
	}
	else
		return string();
}

string getFolderPath( const string &initialPath )
{
	/*bool wasFullScreen = isFullScreen();
     setFullScreen(false);*/
	
	NSOpenPanel *cinderOpen = [NSOpenPanel openPanel];
	[cinderOpen setCanChooseFiles:NO];
	[cinderOpen setCanChooseDirectories:YES];
	[cinderOpen setAllowsMultipleSelection:NO];
	
	NSString *directory = initialPath.empty() ? nil : [[NSString stringWithUTF8String:initialPath.c_str()] stringByExpandingTildeInPath];
	int resultCode = [cinderOpen runModalForDirectory:directory file:nil types:nil];
	
	/*setFullScreen(wasFullScreen);
     restoreWindowContext();*/
	
	if(resultCode == NSOKButton) {
		NSString *result = [[cinderOpen filenames] objectAtIndex:0];
		return string([result UTF8String]);
	}
	else
		return string();
}

string	getSaveFilePath( const string &initialPath, vector<string> extensions )
{
	/*bool wasFullScreen = isFullScreen();
     setFullScreen( false );*/
	
	NSSavePanel *cinderSave = [NSSavePanel savePanel];
	
	NSMutableArray *typesArray = nil;
	if( ! extensions.empty() ) {
		typesArray = [NSMutableArray arrayWithCapacity:extensions.size()];
		for( vector<string>::const_iterator extIt = extensions.begin(); extIt != extensions.end(); ++extIt )
			[typesArray addObject:[NSString stringWithUTF8String:extIt->c_str()]];
		[cinderSave setAllowedFileTypes:typesArray];
	}
	
	NSString *directory = nil, *file = nil;
	if( ! initialPath.empty() ) {
		directory = [[NSString stringWithUTF8String:initialPath.c_str()] stringByExpandingTildeInPath];
		BOOL isDir;
		if( [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir] ) {
			if( ! isDir ) { // a file exists at this path, so directory is its parent
				file = [directory lastPathComponent];
				directory = [directory stringByDeletingLastPathComponent];
			}
		}
		else {
			file = [directory lastPathComponent];
			directory = [directory stringByDeletingLastPathComponent];
		}
	}
	int resultCode = [cinderSave runModalForDirectory:directory file:file];
	
	/*setFullScreen( wasFullScreen );
     restoreWindowContext();*/
	
	if( resultCode == NSOKButton ) {
		string result( [[cinderSave filename] UTF8String] );
		return result;
	}
	else
		return string();
}

@end
