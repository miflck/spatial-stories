//
//  ofxiOSSoundPlayer3D.h
//  iPhone_OSX_BuildTheo
//
//  Created by Theodore Watson on 5/9/13.
//
//

#pragma once

#include "ofxiOSSoundPlayer.h"

class ofxiOSSoundPlayer3D : public ofxiOSSoundPlayer{
    
    public:
        ofxiOSSoundPlayer3D();

        void setLocation(ofPoint pos);
        void setLocation(float x, float y, float z);
        void update();
        void setVolume(float vol);
    
        static void setListenerLocation(float x, float y, float z);
        static void setListenerLocation(ofPoint pos);

        static void setListenerLookAt(float x, float y, float z, ofPoint cameraUp);
        static void setListenerLookAt(ofPoint lookAt, ofPoint cameraUp);
    
        static void setListenerVelocity(ofPoint vel);
        static void setListenerVelocity(float x, float y, float z);
        static void setListenerGain(float gain);
        static void setReferenceDistance(float refDistance);
        static void setMaxDistance(float maxDist);

        ofPoint soundLocation;
        float originalVolume;

    float getArcDirection(float lon1,float lat1, float lon2, float lat2);

    float getArcDistance(float lon1,float lat1, float lon2, float lat2);


};