//
//  Particle.h
//  CCGLParticles example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#include "cinder/gl/gl.h"
#include "cinder/Rand.h"

#import "Particle.h"

using namespace ci;
using namespace std;



Particle::Particle()
{
}

Particle::Particle( int _id, float _descriptors[] )
{
	id = _id;
	for (int i=0; i<12; i++) {
		audioDescriptors[i] = _descriptors[i];
	}
    pRadius = Rand::randFloat(0.5f,3.0f);
}

void Particle::update()
{
}



void Particle::draw()
{
    float gXratio = sin(mTime);
    float gYratio = cos(mTime);
    float gZratio = tan(mTime/id);
    
    glPushMatrix();
	glTranslatef( audioDescriptors[4]*gXratio, audioDescriptors[5]*gYratio, audioDescriptors[6]*gZratio );
    gl::drawSphere( Vec3f(0, 0, 0), pRadius, 16 );
    glPopMatrix();
}
