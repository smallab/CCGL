//
//  MyController.mm
//  CCGLFullScreen example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#import "MyController.h"


@implementation MyController

- (IBAction)listenToGoFullScreenButton:(NSButton*)sender
{
    if ([CinderDrawing isInFullScreenMode] == NO)
        [CinderDrawing enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
    else
        [CinderDrawing exitFullScreenModeWithOptions:nil];
}

@end
