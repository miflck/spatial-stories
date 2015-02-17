//
//  ofxiOSSoundPlayer3D.cpp
//  iPhone_OSX_BuildTheo
//
//  Created by Theodore Watson on 5/9/13.
//
//

#include "ofxiOSSoundPlayer3D.h"

    
static float maxDistance = 3000.0;
static float minDistance = 5.0;
static float listenerGain = 1.0;

static ofPoint listenerPos(0, 0, 100);
static ofPoint listenerLookAt(0, 0, -1);
static ofPoint cameraUp(0, 1, 0);

ofxiOSSoundPlayer3D::ofxiOSSoundPlayer3D(){
    originalVolume = 1.0;
}

void ofxiOSSoundPlayer3D::setLocation(ofPoint pos){
    soundLocation.set(pos);
}

void ofxiOSSoundPlayer3D::setLocation(float x, float y, float z){
    setLocation(ofPoint(x, y, z));
}

void ofxiOSSoundPlayer3D::setVolume(float vol){
    originalVolume = vol;
    ofxiOSSoundPlayer::setVolume(vol);
}

void ofxiOSSoundPlayer3D::update(){

    ofPoint delta = soundLocation - listenerPos;
    float dist = delta.length();
    //---> ev hier auch arc direction einbauen
    
    
    ofVec2f arcDelta=soundLocation - listenerPos;
    
    float arcDist= getArcDistance(soundLocation.x,soundLocation.y,listenerPos.x,listenerPos.y);
    
    dist=arcDist;
    
    //first the pan
    ofPoint lookAtN = listenerLookAt.normalized();
    ofPoint leftRight = lookAtN.crossed(cameraUp);
    
    delta.normalize();
    arcDelta.normalize();
    
    float dotP = leftRight.dot(delta);
    float dotPArc = leftRight.dot(arcDelta);
   // cout<<isLoaded()<<endl;

   // cout<<"dot "<<dotP<<" dotPArc "<<dotPArc<<endl;
    
 

    
   // ofxiOSSoundPlayer::setPan(dotP);
  //  setPan(dotPArc);

    
    //to simulate more sound going into a single ear when the sound is just on one side. 
   // float gainComp = 1.0 + powf(fabs(dotP), 2) * 0.55;
    float gainComp = 1.0 + powf(fabs(dotPArc), 2) * 0.55;

    
    
    ofVec3f soundDir;
        soundDir.set(listenerPos.x,listenerPos.y,0);
        soundDir-=soundLocation;
        float angle = listenerLookAt.angle(soundDir); // angle is 90
        float rearvol=ofMap(angle,0, 180, 0.1, 1);
    
    
    //now the gain
    float gain = powf(ofMap(dist, minDistance, maxDistance, 1, 0, true), 3) * originalVolume * listenerGain *rearvol*gainComp;
    ofxiOSSoundPlayer::setVolume(gain);


}

//static methods

void ofxiOSSoundPlayer3D::setListenerLocation(ofPoint pos){
    listenerPos.set(pos);
}

void ofxiOSSoundPlayer3D::setListenerLocation(float x, float y, float z){
    ofxiOSSoundPlayer3D::setListenerLocation(ofPoint(x, y, z));
}

void ofxiOSSoundPlayer3D::setListenerLookAt(ofPoint lookAt, ofPoint camUp){
    listenerLookAt .set(lookAt);
    cameraUp.set(camUp.normalized());
}

void ofxiOSSoundPlayer3D::setListenerLookAt(float x, float y, float z, ofPoint camUp){
    ofxiOSSoundPlayer3D::setListenerLookAt(ofPoint(x, y, z), camUp);
}


void ofxiOSSoundPlayer3D::setListenerVelocity(ofPoint vel){
    cout << " setListenerVelocity - not implemented " << endl;
}

void ofxiOSSoundPlayer3D::setListenerVelocity(float x, float y, float z){
    ofxiOSSoundPlayer3D::setListenerVelocity(ofPoint(x, y, z)); 
}

void ofxiOSSoundPlayer3D::setListenerGain(float gain){
    listenerGain = gain; 
}

void ofxiOSSoundPlayer3D::setReferenceDistance(float refDistance){
    minDistance = refDistance;
}

void ofxiOSSoundPlayer3D::setMaxDistance(float maxDist){
    maxDistance = maxDist;
}




float ofxiOSSoundPlayer3D::getArcDirection(float lat1,float lon1,float lat2, float lon2){
    
    float dLat = ofDegToRad(lat2-lat1);
    float dLon = ofDegToRad(lon2-lon1);
    lat1 = ofDegToRad(lat1);
    lat2 = ofDegToRad(lat2);
    
    float y = sin(dLon) * cos(lat2);
    float x = cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(dLon);
    float brng = ofRadToDeg(atan2(y, x));
    
    return brng;
    
}

float ofxiOSSoundPlayer3D::getArcDistance(float lat1,float lon1,float lat2, float lon2){
    
    int R = 6371; // km
    float dLat = ofDegToRad(lat2-lat1);
    float dLon = ofDegToRad(lon2-lon1);
    lat1 = ofDegToRad(lat1);
    lat2 = ofDegToRad(lat2);
    
    float a = sin(dLat/2) * sin(dLat/2)+sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2);
    float c = 2 * atan2(sqrt(a), sqrt(1-a));
    float d = R * c;
    return d;
}

