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
#include "ofxGui.h"


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
static Soundcontroller* getInstance();

  // OF  Functions
void setup();
void update();
void draw();
    
    
    
    
    //We need to declare all this mouse events methods to be able to listen to mouse events.
    //All this must be declared even if we are just going to use only one of this methods.
    void mouseMoved(ofMouseEventArgs & args);
    void mouseDragged(ofMouseEventArgs & args);
    void mousePressed(ofMouseEventArgs & args);
    void mouseReleased(ofMouseEventArgs & args);
    
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    
    
  // Location
    ofVec2f devicePosition;
    void setDevicePosition(ofVec2f _devicePosition);
   
    float heading;
    void setHeading(float _heading);
    

    //Location Helper
    float getDistance(float lon1,float lat1, float lon2, float lat2);
    float distance;
    
    float getDirection(float lon1,float lat1, float lon2, float lat2);
    float direction;
    

    void checkMuteSounds();
    
    
    //Soundpoints
    // Load and set Points
    void loadUrl();
    void loadUrlwithPath(string _path);
    
    
    bool bLoadAudio;
    void loadAudioUrlwithPath(string _path, string _filename);
    void urlResponse(ofHttpResponse & response);
    
    
    
    void setPoints(ofxJSONElement _result);
    ofxJSONElement result;
    ofxJSONElement  response;
    
    void loadTourlist();

    int numberOfSounds;
    vector<SoundObject > soundObjects;
    SoundObject superTeaser;
    
    
    int soundsSize;
    
    //ofxOpenALSoundPlayer sounds[SOUNDSSIZE];
    ofVec2f listenerPos;
    ofVec3f listenerDir;

	ofImage compassImg;
    string displaystring;
    
    
    ofxUICanvas *gui;
    ofxUIDropDownList *ddl;
    
    

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