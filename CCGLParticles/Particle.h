//
//  Particle.h
//  CCGLParticles example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://www.smallab.org/code/ccgl/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#include "cinder/Cinder.h"
#include "cinder/Utilities.h"
#include "cinder/Channel.h"
#include "cinder/Vector.h"
#include "cinder/TriMesh.h"
#include "cinder/ObjLoader.h"
#include "cinder/Sphere.h"
#include <stdio.h>
#include <vector>


// GLOBAL VARS
extern double           mTime;


class Particle {
public:
	Particle();
	Particle( int _id, float _descriptors[] );
	void update();
	void associateAG(int graphicID, int audioID);
	void draw();
	
	int					id;
	float				audioDescriptors[12];
    float               pRadius;
};