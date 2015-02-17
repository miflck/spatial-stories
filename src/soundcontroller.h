//
//  soundcontroller.cpp
//  Geosounds
//
//  Created by Michael Flueckiger on 16.04.12.
//  Copyright (c) 2014 Michael Flückiger. All rights reserved.
//

#ifndef GeosoundsMarie_soundcontroller_h
#define GeosoundsMarie_soundcontroller_h




#endif
#define SOUNDSSIZE 3
#define CLOSEDIST 0.005

#import "ofMain.h"
#include "ofxUI.h"
#include "soundObject.h"
#include "ofxJSONElement.h"

//for convenience
#define APPC Soundcontroller::getInstance()

struct soundPoint{
    ofVec2f myPosition;
    float distance;
    float direction;
    string myname;
    int myId;
    bool closest;
    bool isplaying;

};


class Soundcontroller {
    

	
public:
    
   // Soundcontroller ();
  //  ~Soundcontroller ();
    
static Soundcontroller* getInstance();

    
void setup();
void update();
void draw();
void setDevicePosition(ofVec2f _devicePosition);
void setHeading(float _heading);
    
void loadUrl();
    
    
    

    void checkMuteSounds();
    
void setPoints(ofxJSONElement _result);
ofxJSONElement result;
ofxJSONElement  response;


    std::vector<ofImage> images;

    
float heading;
ofVec2f devicePosition; 
    
    int soundsSize;
    
//ofxOpenALSoundPlayer sounds[SOUNDSSIZE];
ofVec2f listenerPos;
ofVec3f listenerDir;

int numberOfSounds;
//vector<soundPoint>  soundPoints;

vector<SoundObject > soundObjects;
    
    
    SoundObject superTeaser;
    
    
    
float getDistance(float lon1,float lat1, float lon2, float lat2);
float distance;
    
float getDirection(float lon1,float lat1, float lon2, float lat2);
float direction;
    
    ofVec2f getXY(float _lat, float _lng);
    
    ofVec2f rotateAroundAxis(ofVec2f vec,ofVec2f origin, float angle );

   
	ofImage compassImg;

    
    string displaystring;
    
    
    ofxUICanvas *gui;
	void guiEvent(ofxUIEventArgs &e);
    
    ofTrueTypeFont nobel;

    
    
    bool drawPadding;
	float red, green, blue; 	
    int closestSoundPointId;    
    
    void onMouseInAnyCircle(int & e);
   void onSteppedOverAnyThreshold(int & e);
    void onSteppedOutAnyThreshold(int & e);

    
    float zoomval;
    
    
    float getSoundObjectByTitle(string title);

    
    
private:
    Soundcontroller ();
	static Soundcontroller* instance;


    
};