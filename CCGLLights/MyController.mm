//
//  MyController.mm
//  CCGLLights example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://www.smallab.org/code/ccgl/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#import "MyController.h"


@implementation MyController

- (IBAction) listenToSliderOutput: (NSSlider*) sender
{
	int value = [sender intValue];
	[CinderDrawing setCubeSize:value];
    [CinderDrawing setNeedsDisplay:YES];
}

- (IBAction) listenToMatSpecSliderOutput: (NSSlider*) sender
{
	int value = [sender intValue];
	[CinderDrawing setMatSpec:value];
    [CinderDrawing setNeedsDisplay:YES];
}

@end
