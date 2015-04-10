//
//  soundcontroller.cpp
//  Geosounds
//
//  Created by Michael Flueckiger on 16.04.12.
//  Copyright (c) 2014 Michael Flückiger. All rights reserved.
//

#include "soundObject.h"
#include "soundcontroller.h"
#include "ofxiOSExtras.h"


// the static event, or any static variable, must be initialized outside of the class definition.
ofEvent<int> SoundObject::clickedInsideGlobal = ofEvent<int>();
ofEvent<int> SoundObject::stepOverThreshold = ofEvent<int>();
ofEvent<int> SoundObject::stepOutThreshold = ofEvent<int>();

float origfadeamount=0.01;
float scalefact=800;

SoundObject :: SoundObject ()
{
    cout << "creating SoundObject" << endl;
    
    teaserradius=0.01;
    radius=0.1;
    maxDistance = 0.1;
    minDistance = 0.001;
    listenerGain = 1.0;
    listenerPos.set(0, 0, 100);
    listenerLookAt.set(0, 0, -1);
    cameraUp.set(0, 1, 0);
    originalVolume=1;
    
    fadeamount=0.1;
    actualFade=1;
    
    actualSoundFade=1;
    actualTeaserFade=0;
    
    isfadeing=false;
    fadespeed=0.05;
    
    teaserFadeTarget=1;
    soundFadeTarget=0;
    
    
    bismute=false;
    muteVolume=0.1;
    
    isInside=false;
    
    teaserPlusRadius=0.006;
    teaserOriginalRadius=10;
    
    nobel.loadFont("TradeGothicLTCom.ttf", 25,true,true);
    
    radiusImg.loadImage("radius.png");
    radiusImg.setAnchorPoint(radiusImg.width/2, radiusImg.height/2);
    
    bRegisteredEvents = false;

    
    
    mindist_mute=0;
    
    
    

    


    
}

SoundObject :: ~SoundObject ()
{
    cout << "destroying SoundObject" << endl;
    clear();

}



//--------------------------------------------------------------
void SoundObject::setup(){
    
    play_teaser=false;
    play_teaser_before=false;
    teaser_threshold=0.01;
    teaservolume=1;
    soundvolume=0;
    
   /* if(!bRegisteredEvents) {
        ofRegisterMouseEvents(this); // this will enable our circle class to listen to the mouse events.
        ofRegisterTouchEvents(this); // this will enable our circle class to listen to the mouse events.
        bRegisteredEvents = true;
    }*/
    
    
  }



//--------------------------------------------------------------
void SoundObject::update(){
    
   //
    
    ofVec2f tempdir(0,-100);
    tempdir.rotate(heading+90); //wieso auch immer…
    setListenerLookAt(tempdir,ofPoint(0,0,-1));
    ofVec2f arcDelta=myPosition - devicePosition;
    float arcDist= getArcDistance(myPosition.x,myPosition.y,devicePosition.x,devicePosition.y);
    float  dist=arcDist;
    
    
    //loadSound
    if( isInEarShot(arcDist, radius)){
        if(!mySound.isLoaded()){
            setSound(mySoundfile);
        }
        if(mySound.isLoaded()){
           if(!mySound.getIsPlaying()) mySound.play();
            if(!myTeaser.getIsPlaying()) myTeaser.play();
        }
    }
    
  
    //unloadSound
    if( !isInEarShot(arcDist, radius)){
        mySound.stop();
        myTeaser.stop();
        if(mySound.isLoaded())mySound.unloadSound();
        if(myTeaser.isLoaded()) myTeaser .unloadSound();
        
    }
    
    
    if(mySound.isLoaded()){
        //first the pan
        ofPoint lookAtN = listenerLookAt.normalized();
        ofPoint leftRight = lookAtN.crossed(cameraUp);
        arcDelta.normalize();
        
        //  float dotP = leftRight.dot(delta);
        float dotPArc = leftRight.dot(arcDelta);
        
        if(arcDist>0.005){
            mySound.setPan(dotPArc);
        }
        else{
            mySound.setPan(0.5);
        }
        myTeaser.setPan(dotPArc);
        
        
        //to simulate more sound going into a single ear when the sound is just on one side.
        float gainComp = 1.0 + powf(fabs(dotPArc), 2) * 0.55;
        float rearvol;
        
        ofVec3f soundDir;
        soundDir.set(devicePosition.x,devicePosition.y,0);
        soundDir-=myPosition;
        float angle = listenerLookAt.angle(soundDir); // angle is 90

        if(play_teaser){
            rearvol=ofMap(angle,100, 180, 0.1, 1,true);
        }
        else{
            //rearvol=1;
            rearvol=ofMap(angle,0, 180, 0.8, 1,true);
        }
        
        float gain = powf(ofMap(dist, minDistance, minTeaserDistance+teaserPlusRadius, 1, 0.8, true), 3) * originalVolume *rearvol* listenerGain*gainComp;

        float teaserGain = powf(ofMap(dist, minDistance, maxTeaserDistance, 1, 0, true), 3)*0.7 *rearvol* listenerGain*gainComp;
        
        actualSoundFade=fadeTo(soundFadeTarget,actualSoundFade);
        actualTeaserFade=fadeTo(teaserFadeTarget,actualTeaserFade);
        
        // Set Volumes
        mySound.setVolume(gain*actualSoundFade);
        myTeaser.setVolume(teaserGain*actualTeaserFade);
        
        // Start over again
        if(play_teaser!=play_teaser_before){
            if(!play_teaser){
              //  ofNotifyEvent(stepOverThreshold, myIndex);
                isInside=true;
                mySound.setPosition(0);
                setSoundFadeTarget(1);
                if(!mySound.getIsPlaying()){
                    mySound.play();
                }
                teaserradius=teaserOriginalRadius+teaserPlusRadius;
                setFadeSpeed(0.05);
                setTeaserFadeTarget(0);
            }
            
            if(play_teaser){
                isInside=false;
                setFadeSpeed(0.08);
                setSoundFadeTarget(0);
                teaserradius=teaserOriginalRadius;
                setTeaserFadeTarget(1);
                //ofNotifyEvent(stepOutThreshold, myIndex);
            }
        }
    }
    
    // Turn off if is OverallTeaser Volumes
    if(arcDist<mindist_mute){
        mySound.setVolume(0);
        myTeaser.setVolume(0);
    }
    play_teaser_before=play_teaser;
}



//--------------------------------------------------------------
void SoundObject::draw(){
 
    
    //scale
    float get_dist=ofClamp(distance, 0,1);
    float dis=ofMap(get_dist, 0,0.1, 0,scalefact);
    float scaledTradius=ofMap(teaserradius, 0,0.1, 0,scalefact);
    float scaledOrigTradius=ofMap(teaserOriginalRadius, 0,0.1, 0,scalefact);
    float scaledRadius=ofMap(radius, 0,0.1, 0,scalefact);
    

    if(mySound.isLoaded()){
    soundpos=mySound.getPosition();
    }
    
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2,ofGetHeight()/2, 0);
    
    
    ofVec2f pointer;
    pointer.set(0,-1);
    pointer*=dis;
    pointer.rotate(direction-heading);
    
    ofSetColor(100,100,255,200);
    ofSetLineWidth(1);
    
    ofTranslate(pointer.x, pointer.y,0);
  
    ofFill();
    ofSetColor(myColor,200);
    radiusImg.draw(-scaledRadius,-scaledRadius,scaledRadius*2,scaledRadius*2);
    ofSetColor(myColor,100);
    if(!play_teaser)drawArcStrip(mySound.getPosition(),ofVec2f(0,0),scaledTradius);
    ofPopMatrix();


}



//--------------------------------------------------------------
void SoundObject::drawCircle(){
    
    ofEnableAlphaBlending();
    
    //scale
    float get_dist=ofClamp(distance, 0,1);
    float dis=ofMap(get_dist, 0,0.1, 0,scalefact);
    float scaledTradius=ofMap(teaserradius, 0,0.1, 0,scalefact);
    
    //float scaledRadius=ofMap(radius, 0,0.1, 0,scalefact);
    
    
    if(mySound.isLoaded()){
        soundpos=mySound.getPosition();
    }
    
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2,ofGetHeight()/2, 0);
    
    ofVec2f pointer;
    pointer.set(0,-1);
    pointer*=dis;
    pointer.rotate(direction-heading);
    
    ofSetLineWidth(1);
    ofTranslate(pointer.x, pointer.y,0);
    

    
    ofFill();
    ofPushStyle();
    ofTranslate(0, 0);
    ofSetColor(myColor,20);
    ofPopStyle();
    
    ofFill();
    ofSetColor(myColor,150);
    radiusImg.draw(-scaledTradius,-scaledTradius,scaledTradius*2,scaledTradius*2);
    ofSetColor(255);
    
    
    
    float textPosition=(-(nobel.stringWidth(myTitle)/2));
    nobel.drawString(myTitle,textPosition,scaledTradius+15);
    ofPopMatrix();
    
}


void SoundObject::setFadeSpeed(float _speed){
    fadespeed=_speed;
    
}


//--------------------------------------------------------------
void SoundObject::setDevicePosition(ofVec2f _devicePosition){
    devicePosition.set(_devicePosition);


}


//--------------------------------------------------------------
void SoundObject::setDeviceHeading(float _heading){
    heading=_heading;
}

//--------------------------------------------------------------
void SoundObject::setPosition(ofVec2f _newPosition){
    myPosition.set(_newPosition);
}

//--------------------------------------------------------------
ofVec2f SoundObject::getPosition(){
    return myPosition;
}

//--------------------------------------------------------------
void SoundObject::setDistance(float _myDistance){
    distance=_myDistance;
}


//--------------------------------------------------------------
float SoundObject::getDistance(){
    return distance;
}

//--------------------------------------------------------------
void SoundObject::setDirection(float _myDirection){
    direction=_myDirection;

}


//--------------------------------------------------------------
float SoundObject::getDirection(){
    return direction;
}

//--------------------------------------------------------------
void SoundObject::setHeading(float _heading){
    heading=_heading;

}



//--------------------------------------------------------------
void SoundObject::loadSound(string fileName){
    mySound.loadSound(fileName);

    
}

//--------------------------------------------------------------
void SoundObject::loadTeaser(string fileName){
    myTeaser.loadSound(fileName);
}


void SoundObject::setSoundfile(string _soundfile){
    mySoundfile=_soundfile;
}

string SoundObject::getSoundfile(){
    return mySoundfile;
}






//void SoundObject::setSound(string fileName){

//}



//--------------------------------------------------------------
void SoundObject::setSound(string fileName){
    
    //cout<<"loading sound and teaser "<<"sounds/"+fileName+".m4a and "<<"sounds/"+fileName+"_teaser.m4a"<<endl;


    try
    {
        
        mySound.loadSound(ofxiPhoneGetDocumentsDirectory() +fileName+".m4a");

        
   //     cout<<"loading sound "<<"sounds/"+fileName+".m4a"<<endl;
    //    mySound.loadSound("sounds/"+fileName+".m4a");
        
    }
    catch (int e)
    {
        cout << "An exception occurred. Exception Nr. " << e << '\n';
    }
    
    try
    {
     //   cout<<"loading teaser "<<"sounds/"+fileName+"_teaser.m4a"<<endl;
        myTeaser.loadSound(ofxiPhoneGetDocumentsDirectory()+fileName+"_teaser.m4a");
    }
    catch (int e)
    {
        cout << "An exception occurred. Exception Nr. " << e << '\n';
    }
    
    
    mySound.setLoop(true);
    mySound.setVolume(0);
    
    maxDistance = radius;
    minDistance = 0.001;
    listenerGain = 1.0;
   
    maxTeaserDistance = radius+0.01;
    minTeaserDistance = teaserradius;
    
    myTeaser.setLoop(true);
    myTeaser.setVolume(0);
    
    myTeaser.play();
    myTeaser.setPan(ofRandom(0,1));
    
    teaservolume=1;
    soundvolume=0;
    
  
}



bool SoundObject::getPlayTeaser(){
    return play_teaser;
}
//--------------------------------------------------------------

void SoundObject::setPlayTeaser(bool _setplayteaser){
    play_teaser=_setplayteaser;
}



void SoundObject::setTeaserThreshold(float _teaserthershold){
    teaser_threshold=_teaserthershold;
}

float SoundObject::getTeaserThreshold(){
    return teaser_threshold;
}


void SoundObject::setTeaserRadius(float _teaserradius){
    teaserradius =_teaserradius;
    teaserOriginalRadius=_teaserradius;
}

float SoundObject::getTeaserRadius(){
    return teaserradius;
}


void SoundObject::setRadius(float _radius){
    radius =_radius;
}

float SoundObject::getRadius(){
    return radius;
}



void SoundObject::setContentId(int _id){
    myContentId=_id;
    cout <<myContentId<<endl;
}



int SoundObject::getContentId(){
    return myContentId;
};



void SoundObject::setIndex(int _index){
    myIndex=_index;

}

int SoundObject::getIndex(){
    return myIndex;
}


void SoundObject::setTitle(string _title){
    myTitle=_title;
}


string SoundObject::getTitle(){
    return myTitle;
}



void SoundObject::startFadeIn(float _target){
    isfadeing=true;
    fadeTarget=_target;
    fadeamount=origfadeamount;
    actualFade=0;
    
}

void SoundObject::endFade(){
    isfadeing=false;
}




void SoundObject::startFadeOut(float _target){
    isfadeing=true;
    fadeTarget=_target;
    fadeamount=-1*origfadeamount;
    actualFade=1;


}


float SoundObject::fade(){
    if(isfadeing){
    actualFade+=fadeamount;
        if(actualFade>1 || actualFade<0)endFade();
    actualFade=ofClamp(actualFade,0,1);
    }
     return actualFade;
}


void SoundObject::setSoundFadeTarget(float _target){
    soundFadeTarget=_target;
}

void SoundObject::setTeaserFadeTarget(float _target){
    teaserFadeTarget=_target;
}

void SoundObject::setFadeTarget(float _target){
    fadeTarget=_target;
}


float SoundObject::fadeTo(float _fadeTarget, float _actualfade){
    
    float target =_fadeTarget;
    float actualfade=_actualfade;
    float fadeDistance = target-actualfade;
    
    if(abs(fadeDistance)<0.01){
        actualfade=target;
        return actualfade;
    }

    float fadefact=fadeDistance*fadespeed;
    actualfade+=fadefact;
    return actualfade;
}



bool SoundObject::isInEarShot(float _dist, float _radius){
    //manage Gui visibility
    bool earshot=false;
    if(_dist<_radius){
        earshot=true;
    }
    return earshot;
}




void SoundObject::clear() {
    if(bRegisteredEvents) {
        ofUnregisterMouseEvents(this); // disable litening to mous events.
        bRegisteredEvents = false;
    }
}






//--------------------------------------------------------------
void SoundObject::touchDown(ofTouchEventArgs & touch){
  //  cout<<"touch inside "<<myContentId<<endl;

    
}

//--------------------------------------------------------------
void SoundObject::touchMoved(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void SoundObject::touchUp(ofTouchEventArgs & touch){
    //    ofNotifyEvent(clickedInsideGlobal, mousePos);
 //   ofNotifyEvent(stepOverThreshold, mousePos);
  //  cout <<mousePos<<endl;
    
    
    if (inside(touch.x, touch.y)) {
        // if the mouse is pressed over the circle an event will be notified (broadcasted)
        // the circleEvent object will contain the mouse position, so this values are accesible to any class that is listening.
        ofVec2f mousePos = ofVec2f(touch.x, touch.y);
   // ofNotifyEvent(stepOverThreshold, 1);
        
        cout<<"I N S I D E"<<endl;
           //ofNotifyEvent(clickedInsideGlobal, myIndex);

        if(!play_teaser){
           // mySound.setPaused(mySound.getIsPlaying());
        }
        else{
           // myTeaser.setPaused(myTeaser.getIsPlaying());
        }

    }

    
    
}

//--------------------------------------------------------------
void SoundObject::touchDoubleTap(ofTouchEventArgs & touch){
    
 APPC->gui->toggleVisible();
    
    
    ofVec2f mousePos = ofVec2f(touch.x, touch.y);
    
    
}

//--------------------------------------------------------------
void SoundObject::touchCancelled(ofTouchEventArgs & touch){
    
}


void SoundObject::mouseMoved(ofMouseEventArgs & args){}
void SoundObject::mouseDragged(ofMouseEventArgs & args){}
void SoundObject::mousePressed(ofMouseEventArgs & args){}
void SoundObject::mouseReleased(ofMouseEventArgs & args){
 
}



float SoundObject::getArcDirection(float lat1,float lon1,float lat2, float lon2){
    
    float dLat = ofDegToRad(lat2-lat1);
    float dLon = ofDegToRad(lon2-lon1);
    lat1 = ofDegToRad(lat1);
    lat2 = ofDegToRad(lat2);
    
    float y = sin(dLon) * cos(lat2);
    float x = cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(dLon);
    float brng = ofRadToDeg(atan2(y, x));
    
    return brng;
    
}

float SoundObject::getArcDistance(float lat1,float lon1,float lat2, float lon2){
    
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




void SoundObject::setListenerLookAt(ofPoint lookAt, ofPoint camUp){
    listenerLookAt .set(lookAt);
    cameraUp.set(camUp.normalized());
}



//this function checks if the passed arguments are inside the circle.
bool SoundObject::inside(float _x, float _y ){
  //  float scaledTradius=ofMap(teaserradius, 0,0.1, 0,1000);
    
    
    
    //scale
    float get_dist=ofClamp(distance, 0,0.100);
    float dis=ofMap(get_dist, 0,0.1, 0,1000);
    float scaledTradius=ofMap(teaserradius, 0,0.1, 0,1000);
    float scaledRadius=ofMap(radius, 0,0.1, 0,1000);
    
    ofVec2f pointer;
    pointer.set(0,-1);
    pointer*=dis;
    pointer.rotate(direction-heading);
    ofSetColor(100,100,255,200);
    
    
    ofVec2f touch;
    ofVec2f translated_pointer;
    translated_pointer.set(ofGetWidth()/2, ofGetHeight()/2);
    translated_pointer+=pointer;
    touch.set(ofVec2f(_x, _y));
    
    
 //   cout<<touch<<" pointer "<<translated_pointer<<" dist "<<touch.distance(translated_pointer)<<" radius "<<scaledRadius<<endl;
    
    return (touch.distance(translated_pointer) < (scaledTradius*0.7));
}



void SoundObject::setColor(string _color){
    ofStringReplace(_color, "#", "0x");
    ofColor c = ofColor::fromHex(ofHexToInt(_color));
    myColor=ofColor(c);
}




void SoundObject::setSacleFact(float _scalefact){
    scalefact=_scalefact;
}


float SoundObject::fadeOut(){

}

float SoundObject::fadeIn(){
}



void SoundObject::setMute(bool _mute){
    bismute=_mute;

}


bool SoundObject::getMute(){
    return bismute;
}

bool SoundObject::getIsInside(){
    return isInside;

}





void SoundObject::setMinDistMute(float _mindist){
    mindist_mute=_mindist;
}

float SoundObject::getMinDistMute(){
    return mindist_mute;
}



void SoundObject::drawArcStrip(float percent, ofVec2f center, float radius)
{
    float theta = ofxUIMap(percent, 0, 1, 0, 360.0, true);
    
    float outerRadius=radius;
    float innerRadius=20;
    ofPushMatrix();
  //  ofTranslate(rect->getX(),rect->getY());
    
    ofBeginShape();
    
    {
        float x = sin(-ofDegToRad(0));
        float y = cos(-ofDegToRad(0));
        ofVertex(center.x+outerRadius*x,center.y+outerRadius*y);
    }
    
    for(int i = 0; i <= theta; i+=10)
    {
        float x = sin(-ofDegToRad(i));
        float y = cos(-ofDegToRad(i));
        
        ofVertex(center.x+outerRadius*x,center.y+outerRadius*y);
    }
    
    {
        float x = sin(-ofDegToRad(theta));
        float y = cos(-ofDegToRad(theta));
        ofVertex(center.x+outerRadius*x,center.y+outerRadius*y);
        ofVertex(center.x+innerRadius*x,center.y+innerRadius*y);
    }
    
    for(int i = theta; i >= 0; i-=10)
    {
        float x = sin(-ofDegToRad(i));
        float y = cos(-ofDegToRad(i));
        
        ofVertex(center.x+innerRadius*x,center.y+innerRadius*y);
    }
    
    {
        float x = sin(-ofDegToRad(0));
        float y = cos(-ofDegToRad(0));
        ofVertex(center.x+innerRadius*x,center.y+innerRadius*y);
    }
    
    ofEndShape();
    ofPopMatrix();
}

