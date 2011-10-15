//
//  MyController.mm
//  CCGLBlobDetection example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://www.smallab.org/code/ccgl/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#import "MyController.h"


@implementation MyController

- (IBAction) listenToBlobLevelsSlider:(NSSlider *)sender
{
	int value = [sender intValue];
	[CinderDrawing setBlobLevels:value];
    [CinderDrawing setNeedsDisplay:YES];
}

- (IBAction) listenTo3dEffectSlider:(NSSlider *)sender
{
	int value = [sender intValue];
	[CinderDrawing set3dEffect:value];
    [CinderDrawing setNeedsDisplay:YES];
}

- (IBAction) listenToResetCameraButton: (NSButton*) sender
{
	[CinderDrawing resetCamera];
    [CinderDrawing setNeedsDisplay:YES];
}

- (IBAction) listenToShowFeedButton: (NSButton*) sender
{
	[CinderDrawing showFeed:[sender state]];
    [CinderDrawing setNeedsDisplay:YES];
}

- (IBAction) listenToGoFullScreenButton: (NSButton*) sender
{
    if ([CinderDrawing isInFullScreenMode] == NO)
        [CinderDrawing enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
    else
        [CinderDrawing exitFullScreenModeWithOptions:nil];
}

@end
