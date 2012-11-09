//
//  ParticleController.cpp
//  CCGLParticles example
//
//  Created by Matthieu Savary on 03/03/11.
//  Copyright (c) 2011 SMALLAB.ORG. All rights reserved.
//
//  More info on the CCGL project >> http://cocoacid.org/mac/
//  License & disclaimer >> see license.txt file included in the distribution package
//

#include "cinder/Rand.h"
#include "cinder/Vector.h"

#import "ParticleController.h"

using namespace ci;
using std::list;

ParticleController::ParticleController()
{
}

void ParticleController::update()
{
	for( list<Particle>::iterator p = mParticles.begin(); p != mParticles.end(); ++p ) {
		p->update();
	}
}

void ParticleController::showParticles()
{
}

void ParticleController::draw()
{
    int counter = 0;
	for( list<Particle>::iterator p = mParticles.begin(); p != mParticles.end(); ++p ) {
        if (counter<mPAmount)
            p->draw();
        else
            break;
        counter++;
	}
}

void ParticleController::addParticle(int id, float descriptors[])
{
	mParticles.push_back( Particle( id, descriptors ) );
}

void ParticleController::empty()
{
	for( int i=0; i<mParticles.size(); i++ )
	{
		mParticles.pop_back();
	}
}
