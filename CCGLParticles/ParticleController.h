//
//  ParticleController.h
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
#include "Particle.h"
#include <stdio.h>
#include <list>

extern int          mPAmount;

class ParticleController {
public:
	ParticleController();
	void update();
	void showParticles();
	void draw();
	void addParticle( int id, float descriptors[] );
	void empty();
	
	std::list<Particle>	mParticles;
};