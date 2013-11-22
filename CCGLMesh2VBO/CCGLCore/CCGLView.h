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

#define CINDER_MAC

#include "cinder/Cinder.h"
#include "cinder/Camera.h"
#include "cinder/ImageIo.h"
#include "cinder/app/Event.h"
#include "cinder/app/MouseEvent.h"
#include "cinder/app/KeyEvent.h"
#include "cinder/app/FileDropEvent.h"
#include "cinder/DataSource.h"
#include "cinder/Exception.h"
#include "cinder/Utilities.h"
#include "cinder/gl/gl.h"
#include "cinder/gl/Texture.h"
#include "cinder/Area.h"
#include "cinder/Surface.h"
#include "cinder/ip/Flip.h"

#import <Cocoa/Cocoa.h>
#include <stdio.h>

using namespace cinder;
using namespace cinder::app;
using namespace std;

@interface CCGLView : NSOpenGLView
{
	NSTimer *drawTimer;
	int frameCount;
	float frameRate;
	bool mMouseShiftDown;
	bool mRightMouseShiftDown;
	bool mKeyShiftDown;
	::CFAbsoluteTime startTime;
	bool appSetupCalled;
}

/**
 *	Preparing to draw
 */

- (void) setup;
- (void) glView;
- (void) glParams;

/**
 *  Actual drawing
 */

- (void) draw;

/**
 *  Cocoa'd general utils extracted from Cinder
 */

- (double) getElapsedSeconds;
- (int) getWindowWidth;
- (int) getWindowHeight;
- (Area)	getWindowBounds;
- (Surface) copyWindowSurface;
- (Surface) copyWindowSurface:(Area) area;
- (float) getWindowAspectRatio;
- (bool) withinDrawingBoundsX:(int)x Y:(int)y;

/**
 *  Events
 */

- (void) dragAndDropFiles:(NSArray *)filenames;

/**
 *	Cursor utils
 */

void arrowCursor();
void openHandCursor();
void closedHandCursor();
void showCursor();
void hideCursor();

/**
 *  Cinder's cout alias
 */

ostream&	console();

/**
 *  Cinder's resource handling gone slightly or very Cocoa
 */

//! Cinder's Exception for failed resource loading
class ResourceLoadExc : public Exception
{
public:
	ResourceLoadExc( const string &macPath );
	virtual const char * what() const throw() { return mMessage; }
	char mMessage[4096];
};
//! Cinder's
//! Returns a DataSourceRef to an application resource. \a macPath is a path relative to the bundle's resources folder. Throws ResourceLoadExc on failure. \sa \ref CinderResources
- (DataSourcePathRef)	loadResource:(string) macPath;
//! Returns the absolute file path to a resource located at \a rsrcRelativePath inside the bundle's resources folder. Throws ResourceLoadExc on failure. \sa \ref CinderResources
- (string)			getResourcePath:(string) rsrcRelativePath;
/*//! Returns the absolute file path to the bundle's resources folder. \sa \ref CinderResources
 static std::string			getResourcePath();*/
//! Presents the user with a file-open dialog and returns the selected file path.
/** The dialog optionally begins at the path \a initialPath and can be limited to allow selection of files ending in the extensions enumerated in \a extensions.
 If the active app is in full-screen mode it will temporarily switch to windowed-mode to present the dialog.
 \return the selected file path or an empty string if the user cancelled. **/
string		getOpenFilePath( const std::string &initialPath = "", std::vector<std::string> extensions = std::vector<std::string>() );
//! Presents the user with a folder-open dialog and returns the selected folder.
string		getFolderPath(const std::string &initialPath="");
//! Presents the user with a file-save dialog and returns the selected file path.
/** The dialog optionally begins at the path \a initialPath and can be limited to allow selection of files ending in the extensions enumerated in \a extensions.
 If the active app is in full-screen mode it will temporarily switch to windowed-mode to present the dialog.
 \return the selected file path or an empty string if the user cancelled. **/
string		getSaveFilePath( const std::string &initialPath = "", std::vector<std::string> extensions = std::vector<std::string>() );

@end
