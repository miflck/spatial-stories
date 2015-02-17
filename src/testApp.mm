#include "testApp.h"
#include "soundcontroller.h"


//--------------------------------------------------------------
void testApp::setup(){
    
    
    ofSetCircleResolution(60);
	//ofBackground(0, 0, 0);
     ofBackground(200);

	ofSetFrameRate(60);
    
    
    width= ofGetScreenWidth();
    height=ofGetScreenHeight();
    
    
	// register touch events
	ofRegisterTouchEvents(this);
	
	// initialize the accelerometer
	ofxAccelerometer.setup();
	
	//iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);
    
	coreLocation = new ofxiPhoneCoreLocation();
	hasCompass = coreLocation->startHeading();
    hasGPS = coreLocation->startLocation();
    
    
    APPC->setup();

    
   // soundcont.setup();
    
	heading = 0.0;
    
    
    homePosition.set(47.365906,8.520262);

   
 

}

//--------------------------------------------------------------
void testApp::update(){
    //heading = ofLerpDegrees(heading, -coreLocation->getTrueHeading(), 0.7);
	heading = coreLocation->getMagneticHeading();
    cout<<coreLocation->getTrueHeading()<<endl;
    
    
    if(hasGPS){
        deviceposition.set(coreLocation->getLatitude(),coreLocation->getLongitude());
        //soundcont.setDevicePosition(deviceposition);
       APPC->setDevicePosition(deviceposition);
    }
    
   // soundcont.setHeading(heading);
   // soundcont.update();
    APPC->setHeading(heading);
    APPC->update();
    

}

//--------------------------------------------------------------
void testApp::draw(){
    
    /*ofSetColor(54);
	ofDrawBitmapString("Heading: ", 8, 10);
    ofDrawBitmapString(ofToString(coreLocation->getTrueHeading()), 80,10);
	ofDrawBitmapString("Heading Accuracy: ", 8, 30);
    ofDrawBitmapString(ofToString(coreLocation->getHeadingAccuracy()), 200,30);
    ofDrawBitmapString("Position Accuracy: ", 8, 50);
    ofDrawBitmapString(ofToString(coreLocation->getLocationAccuracy()), 200,50);
    ofDrawBitmapString("Position : ", 8, 70);
    ofDrawBitmapString(ofToString(deviceposition), 200,90);
    
    */
    //soundcont.draw();
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

  //  soundcont.gui->toggleVisible();
   // cout<<"double"<<endl;
    


    
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

