//
//  MyController.h
//  CCGLBasic example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#import <Cocoa/Cocoa.h>


@interface MyController : NSObject {
	IBOutlet id CinderDrawing;
}

- (IBAction) listenToCubeSizeSlider: (NSSlider*) sender;

@end