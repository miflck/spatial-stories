//
//  soundObject.h
//  GeosoundsMarie
//
//  Created by Michael Flueckiger on 3.3.2014
//  Copyright (c) 2014 Michael Flückiger. All rights reserved.
//


#ifndef ColorWindows_ScreenSaverController_h
#define ColorWindows_ScreenSaverController_h

#include "ofMain.h"
#include "Poco/RegularExpression.h"
#include "ofxJSONElement.h"
#include "ofxUI.h"
#include "ofxiOSSoundPlayer.h"
#include "ofxiOSSoundPlayer3D.h"



class SoundObject{

public:
    
    SoundObject ();
   ~SoundObject ();
    
    
    static ofEvent<int> clickedInsideGlobal;
    static ofEvent<int> stepOverThreshold;
   static ofEvent<int> stepOutThreshold;


    
    bool isInside;
    bool getIsInside();
    
    void setup();
    void update();
    void draw();
    void clear();

    
    
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
    
    
    void loadSound(string fileName);
    void loadTeaser(string fileName);

    void setSound(string fileName);

    
    void setContentId(int _id);
    int getContentId();
    int myContentId;
    

    
    void setIndex(int _index);
    int getIndex();
    int myIndex;
    

    // --- Sound File ----
    void setSoundfile(string _soundfile);
    string getSoundfile();
    string mySoundfile;
    
    void setTitle(string _title);
    string getTitle();
    string myTitle;

    
    void setColor(string _color);
    ofColor myColor;
    
    
    ofxiOSSoundPlayer mySound;
    ofxiOSSoundPlayer myTeaser;
    ofxiOSSoundPlayer synth;

    ofTrueTypeFont nobel;


    ofImage radiusImg;

    
    // Position
    void setPosition(ofVec2f _newPosition);
    ofVec2f getPosition();

    
    // Device Position
    ofVec2f devicePosition;
    void setDevicePosition(ofVec2f _devicePosition);
    void setDeviceHeading(float _heading);
    void setHeading(float _heading);
    
    
    void setDistance(float _myDistance);
    void setDirection(float _myDirection);
    

    
    float getDirection();
    float getDistance();
   
    
    //-------- Teaser -----------
    // Teaser Radius In and Out
    float teaserPlusRadius;
    float teaserOriginalRadius;
    
    bool getPlayTeaser();
    void setPlayTeaser(bool _setplayteaser);
    
    float getTeaserThreshold();
    void setTeaserThreshold(float _teaserthreshold);

    float getTeaserRadius();
    void setTeaserRadius(float _teaserradius);
     float teaserradius;
    
    float getRadius();
    void setRadius(float _radius);
    
    
    float radius;
    void crossfadeSounds();

    
     void setListenerLookAt(float x, float y, float z, ofPoint cameraUp);
     void setListenerLookAt(ofPoint lookAt, ofPoint cameraUp);
    
    float maxDistance;// = 3000.0;
    float minDistance;// = 5.0;
    
    float maxTeaserDistance;// = 3000.0;
    float minTeaserDistance;// = 5.0;
    
    float listenerGain;// = 1.0;
    
    ofPoint listenerPos;//(0, 0, 100);
    ofPoint listenerLookAt;//(0, 0, -1);
    ofPoint cameraUp;//(0, 1, 0);

    float originalVolume;
    
    //this function checks if the passed arguments are inside the circle.
    bool inside(float _x, float _y );
    bool isInEarShot(float _dist, float _radius);
    void setSacleFact(float _scalefact);
    void drawCircle();
    
  
    ofxUIRotarySlider *mySlider;
    ofxUIWidget *widget;
    
    
    float fadeOut();
    float fadeIn();
    float fade();
    
    float fadespeed;
    
    float fadeTo(float fadeTarget,float _actualFade);
    
    
    float soundfileFade();

 
    void startSoundFadeIn(float _target);
    
    
    void startSoundFadeOut(float _target);
    void endSoundFade();
    
    
    void startFadeIn(float _target);
    void endFadeIn();

    
    void startFadeOut(float _target);
    void endFade();
    
    void setFadeTarget(float _target);

    void setTeaserFadeTarget(float _target);
    void setSoundFadeTarget(float _target);
    
    float fadeTarget;
    
    float teaserFadeTarget;
    float soundFadeTarget;
    
    float actualFade;
    float actualSoundFade;
    float actualTeaserFade;
    float fadeamount;
    
    void setMute(bool _mute);
    bool getMute();
    
    void drawArcStrip(float percent, ofVec2f center, float radius);
    
   // ofVec3f center;
    
    void setFadeSpeed(float _speed);
    
    void setMinDistMute(float _mindist);
    float getMinDistMute();
    
    
private:
    
    float mindist_mute;
    
    float muteVolume;
    
    bool bismute;
    
    bool isfadeing;
    bool bisInEarshot;
    
    bool bRegisteredEvents;

    
    ofImage pointerImg;

    
    float distance;
    float direction;
    
    float heading;
    ofVec2f myPosition;
    
    
    bool play_teaser;
    bool play_teaser_before;

    float teaser_threshold;
    float teaser_faderadius;
    
    float teaservolume;
    float soundvolume;
    
    float soundpos;
    
    float getArcDirection(float lon1,float lat1, float lon2, float lat2);
    float getArcDistance(float lon1,float lat1, float lon2, float lat2);
	
    float red, green, blue;

    

    
    
};

#endif
