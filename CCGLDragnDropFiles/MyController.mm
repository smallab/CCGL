//
//  MyController.mm
//  CCGLDragnDropFiles example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
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

@end
