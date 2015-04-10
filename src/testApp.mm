#include "testApp.h"
#include "soundcontroller.h"


//--------------------------------------------------------------
void testApp::setup(){
    
    //Graphic Settings
    ofBackground(100);
    ofSetCircleResolution(60);
	ofSetFrameRate(60);
    
	// register touch events
	ofRegisterTouchEvents(this);
	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	//iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);
    
    //Location Vars
	coreLocation = new ofxiPhoneCoreLocation();
	hasCompass = coreLocation->startHeading();
    hasGPS = coreLocation->startLocation();
    heading = 0.0;

    
    //APPController Singleton
    APPC->setup();
}

//--------------------------------------------------------------
void testApp::update(){
    //heading = ofLerpDegrees(heading, -coreLocation->getTrueHeading(), 0.7);
	heading = coreLocation->getMagneticHeading();
    
    if(hasGPS){
        //Update Location
        deviceposition.set(coreLocation->getLatitude(),coreLocation->getLongitude());
        APPC->setDevicePosition(deviceposition);
    }
    //update Heading
    APPC->setHeading(heading);
    
    //update Appcontroller
    APPC->update();
    
}

//--------------------------------------------------------------
void testApp::draw(){
    APPC->draw();
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
   
    
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
   APPC->gui->toggleVisible();
  }

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}

