//
//  soundcontroller.cpp
//  Geosounds
//
//  Created by Michael Flueckiger on 16.04.12.
//  Copyright (c) 2014 Michael Flückiger. All rights reserved.
//

#include "soundcontroller.h"
#include "ofxiOSExtras.h"


Soundcontroller* Soundcontroller::instance = 0;

Soundcontroller* Soundcontroller::getInstance() {
	if (!instance) {
		instance = new Soundcontroller();
	}
	return instance;
}



Soundcontroller :: Soundcontroller ()
{
    cout << "creating Soundcontroller" << endl;
}

/*Soundcontroller :: ~Soundcontroller ()
{
    cout << "destroying Soundcontroller" << endl;
}*/



//--------------------------------------------------------------
void Soundcontroller::setup(){
   
    nobel.loadFont("TradeGothicLTCom.ttf", 25,true,true);
    displaystring="";
    zoomval=800;
    //----------------------------------
 //   gui = new ofxUICanvas(0,ofGetHeight(),ofGetWidth(),500);
   // gui = new ofxUICanvas(0,0,200,ofGetHeight());
    
    
    gui = new ofxUICanvas(0,ofGetHeight()-100,ofGetWidth(),100);

    ofColor pad = ofColor(0,255,0,0);
    ofColor backgroundcolor = ofColor(255,150);
    ofColor outlinecolor = ofColor(255,0,0,200);
    ofColor paddingColor = ofColor(0,0,0,150);
  //  ofColor fillcolor = ofColor(myColor,200);
    
    ofColor highlightcolor = ofColor(0,0,0,100);
    ofColor paddingoutline = ofColor(0,255,0,255);
    
    
    
    gui->setDrawWidgetPadding(1);
    gui->setDrawBack(true);
    gui->setDrawPadding(false);
    gui->setDrawPaddingOutline(false);
    gui->setDrawOutline(false);

    
     gui->setColorBack(backgroundcolor);
   //  gui->setColorFill(fillcolor);
     gui->setColorOutline(outlinecolor);
     gui->setColorFillHighlight(highlightcolor);
     gui->setColorOutlineHighlight(highlightcolor);
     gui->setColorPadded(pad);
     gui->setColorPaddedOutline(paddingoutline);
     
    
    

   gui->addWidgetDown(new ofxUILabel("ZOOMSlider", OFX_UI_FONT_MEDIUM));
   // gui->addWidgetDown(new ofxUIToggle(32, 32, false, "STOP"));
    


    gui->addWidgetDown(new ofxUISlider("Zoom",100,1000,&zoomval,ofGetWidth()-100,30));
    ofAddListener(gui->newGUIEvent, this, &Soundcontroller::guiEvent);
 
    
    gui->setVisible(false);
    gui->setAutoDraw(true);
    
    
    compassImg.loadImage("dir.png");
    compassImg.setAnchorPoint(compassImg.width/2, compassImg.height);

    
    ofVec2f tempPos(ofGetWidth()/2,0);
        
    
    soundObjects.clear();
    
    
    //INIT OPENAL
    
    listenerPos.set(devicePosition);
    listenerDir.set(0,-1,0);
    
    loadUrl();

    ofAddListener(SoundObject::clickedInsideGlobal , this, &Soundcontroller::onMouseInAnyCircle);//listening to this event will enable us to get events from any instance of the circle class as this event is static (shared by all instances of the same class).

    ofAddListener(SoundObject::stepOverThreshold , this, &Soundcontroller::onSteppedOverAnyThreshold);//listening to this event will enable us to get events from any instance of the circle class as this event is static (shared by all instances of the same class).

   ofAddListener(SoundObject::stepOutThreshold , this, &Soundcontroller::onSteppedOutAnyThreshold);//listening to this event will enable us to get events from any instance of the circle class as this event is static (shared by all instances of the same class).

    
    
    /*
    superTeaser;
    
    
    string lat = points[i]["lat"].asString();
    string lon = points[i]["lng"].asString();
    string cont_id = points[i]["content_id"].asString();
    string title = points[i]["title"].asString();
    string filename = points[i]["filename"].asString();
    
    string sRad = points[i]["radius"].asString();
    string sTeaserRad = points[i]["teaserradius"].asString();
    string color = points[i]["color"].asString();
    
    
    
    float dlat=ofToFloat(lat);
    float dlng=ofToFloat(lon);
    int content_id=ofToInt(cont_id);
    float rad=ofToFloat(sRad);
    rad/=1000;
    float teaserradius=ofToFloat(sTeaserRad);
    teaserradius/=1000;
    
    
    
    tempPos.set(dlat,dlng);
    so.setPosition(tempPos);
    so.setContentId(content_id);
    so.setIndex(i);
    
    so.setTitle(title);
    so.setSoundfile(filename);
    so.setTeaserRadius(teaserradius);
    so.setRadius(rad);
    so.setColor(color);
*/
    
    
    cout<<"finished setup soundcontroller"<<endl;
    
}



//--------------------------------------------------------------
void Soundcontroller::update(){
    
    for (int i=0;i<soundObjects.size();i++){
        float distance=getDistance(devicePosition.x,devicePosition.y,soundObjects[i].getPosition().x,soundObjects[i].getPosition().y);
        float direction=getDirection(devicePosition.x,devicePosition.y,soundObjects[i].getPosition().x,soundObjects[i].getPosition().y);
        soundObjects[i].setDistance(distance);
        soundObjects[i].setDirection(direction);
        soundObjects[i].setDevicePosition(listenerPos);
        soundObjects[i].setDeviceHeading(heading);
        if(distance<soundObjects[i].getTeaserRadius()){
            soundObjects[i].setPlayTeaser(0);
        }else{
           soundObjects[i].setPlayTeaser(1);
        }
        soundObjects[i].update();
    }
    
    checkMuteSounds();
}





//--------------------------------------------------------------
void Soundcontroller::draw(){
    
    
    ofSetColor(255,255,255);
    
    

    ofVec2f tempdir(0,0);
    ofVec2f origin(ofGetWidth()/2,ofGetHeight()/2);
 
    ofEnableAlphaBlending();

    
  //  glBlendFunc(GL_ONE, GL_ONE);
//glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    
    for (int i=0;i<soundObjects.size();i++){
     soundObjects[i].draw();
    }
    
   // ofDisableAlphaBlending();

    /*
    for (int i=0;i<soundObjects.size();i++){
      //  soundObjects[i].gui->draw();
    }*/
    
    ofDisableAlphaBlending();

   // gui->draw();
    
  //  ofEnableAlphaBlending();
  //  glBlendFunc(GL_SRC_ALPHA, GL_ONE);

    for (int i=0;i<soundObjects.size();i++){
        soundObjects[i].drawCircle();
    }

    

    ofEnableAlphaBlending();

    
    ofSetColor(255,200);
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2,ofGetHeight()/2, 0);
    compassImg.draw(0,0);
    ofSetColor(255,255);
    ofFill();
    ofCircle(0,0,20);
	ofPopMatrix();
    ofFill();
     
    
    //ofSetColor(0, 0, 0);
    //ofRect(0, 0, ofGetWidth(), 70);
    //ofSetColor(255);
    //nobel.drawString(displaystring,0,50);
    
}


//--------------------------------------------------------------
void Soundcontroller::setDevicePosition(ofVec2f _devicePosition){
    devicePosition=_devicePosition;  
    listenerPos=devicePosition;
}



//--------------------------------------------------------------
void Soundcontroller::setHeading(float _heading){
    heading=_heading;
    
}




ofVec2f Soundcontroller::getXY(float _lat, float _lng)
{
    float mapWidth=ofGetWidth();
    float mapHeight=ofGetScreenHeight();
    
    float screenX = ((_lng + 180) * (mapWidth  / 360));
      float screenY =  (((_lat * -1) + 90) * (mapHeight/ 180));
    
    return  ofVec2f(screenX,screenY);
}


//--------------------------------------------------------------
void Soundcontroller::setPoints(ofxJSONElement _result){
    ofxJSONElement points =_result;
    
  soundObjects.clear();
      
    cout<<"there are "<<points.size()<<" sounds"<<endl;
      
    ofVec2f tempPos(ofGetWidth()/2,0);
    
    SoundObject so;
	for(int i=0; i<points.size(); i++)
	{
		string lat = points[i]["lat"].asString();
        string lon = points[i]["lng"].asString();
        string cont_id = points[i]["content_id"].asString();
        string title = points[i]["title"].asString();
        string filename = points[i]["filename"].asString();

        string sRad = points[i]["radius"].asString();
        string sTeaserRad = points[i]["teaserradius"].asString();
        string color = points[i]["color"].asString();
        
        
        
        float dlat=ofToFloat(lat);
        float dlng=ofToFloat(lon);
        int content_id=ofToInt(cont_id);
        float rad=ofToFloat(sRad);
        rad/=1000;
        float teaserradius=ofToFloat(sTeaserRad);
        teaserradius/=1000;
        

        
        tempPos.set(dlat,dlng);
        so.setPosition(tempPos);
        so.setContentId(content_id);
        so.setIndex(i);

        so.setTitle(title);
        so.setSoundfile(filename);
        so.setTeaserRadius(teaserradius);
        so.setRadius(rad);
        so.setColor(color);
        
        soundObjects.push_back(so);
        
        
        // irgendwie muss das nachher geschehen weil sonst der Player das file nicht findet.
        //-> ev weil das laden nicht vor dem verschieben abgeschlossen ist?
     //   soundObjects[soundObjects.size()-1].setup();
        
     }
}


/*
//--------------------------------------------------------------

ofVec2f Soundcontroller::rotateAroundAxis(ofVec2f vec,ofVec2f origin, float angle ){
    
    float xnew=origin.x+((vec.x-origin.x)*cos(angle)-(origin.y-vec.y)*sin(angle));
    float ynew=origin.y+((origin.y-vec.y)*cos(angle)-(vec.x-origin.x)*sin(angle));
    //float xnew=((vec.x-origin.x)*cos(angle)-(origin.y-vec.y)*sin(angle));
    //float ynew=((origin.y-vec.y)*cos(angle)-(vec.x-origin.x)*sin(angle));
    
    ofVec2f newPos;
    newPos.set(xnew,ynew);
    
    return newPos;
}

*/


//--------------------------------------------------------------

void Soundcontroller::loadUrl(){

   std:: string url = "http://leichtbautester.michaelflueckiger.ch/frontend/getPoints";
 //  std:: string url = "http://huggler.michaelflueckiger.ch/frontend/getPoints";
    
    bool parsingSuccessful=result.open(url);
    cout <<"parsing "<<parsingSuccessful<<endl;
  
    
	if (!response.open(url)) {
		cout  << "Failed to parse JSON\n No Response…" << endl;
        ofFile file(ofxiPhoneGetDocumentsDirectory() +"mySavedPoints.txt",ofFile::ReadOnly);
        ofBuffer buff = file.readToBuffer();
        result=buff.getText();
        setPoints(result);

	}
    

    if ( parsingSuccessful )
    {
    cout << result.getRawString() << endl;

        cout<<ofxiPhoneGetDocumentsDirectory()<<endl;
        
       ofFile file(ofxiPhoneGetDocumentsDirectory() +"mySavedPoints.txt",ofFile::WriteOnly);
        file << response.getRawString() << endl;
        file.close();

        setPoints(result);
        for(int i=0;i<soundObjects.size();i++){
            //soundObjects[i].setSound(soundObjects[i].getSoundfile());
            soundObjects[i].setup();

        }
	}
    else
    {
		cout  << "Failed to parse JSON. Try local" << endl;
        bool parsingSuccessful=result.open(ofxiPhoneGetDocumentsDirectory()+"mySavedPoints.txt");
        setPoints(result);
        for(int i=0;i<soundObjects.size();i++){
            soundObjects[i].setSound(soundObjects[i].getSoundfile());
            soundObjects[i].setup();
        }
        
	}
}

//--------------------------------------------------------------
void Soundcontroller::onMouseInAnyCircle(int & e){
    displaystring="clicked in"+ofToString(e);
    cout<<"clicked in"<<e<<endl;

    
    
   /* if(soundObjects[e].mySound.getIsPlaying()){
        cout<<"set Mute"<<e<<endl;

    for(int i=0;i<soundObjects.size();i++){
        soundObjects[i].setMute(true);

    }
    }else{
        for(int i=0;i<soundObjects.size();i++){
            soundObjects[i].setMute(false);
        }
    
    }*/
    
}


//--------------------------------------------------------------
void Soundcontroller::onSteppedOverAnyThreshold(int & e){
    cout<<"someone stepped over the threshold of"<<e<<endl;
    displaystring="stepped over "+ofToString(e);
    
    
    soundObjects[e].setFadeSpeed(0.05);

    
    for(int i=0;i<soundObjects.size();i++){
        //soundObjects[i].setMute(true);
    }

    
  //  gui->toggleVisible();
}






//--------------------------------------------------------------
void Soundcontroller::onSteppedOutAnyThreshold(int & e){
    cout<<"someone stepped over the threshold of"<<e<<endl;
    //  gui->toggleVisible();
    
    
     soundObjects[e].setFadeSpeed(0.05);
    
   /* displaystring="stepped out "+ofToString(e);
    bool inside=false;
   
    for(int i=0;i<soundObjects.size();i++){
        if( soundObjects[i].getIsInside()){
            inside=true;
        }
    }
    
    if(!inside){
    for(int i=0;i<soundObjects.size();i++){
      //  soundObjects[i].setMute(false);
    }
    }
*/

}

//--------------------------------------------------------------

void Soundcontroller::checkMuteSounds(){
    bool inside=false;
    int index;
    
    for(int i=0;i<soundObjects.size();i++){
        if( soundObjects[i].getIsInside()){
            inside=true;
            index=i;
        }
    }
    
    if(!inside){
        for(int i=0;i<soundObjects.size();i++){
           // soundObjects[i].setMute(false);
           // soundObjects[i].setTeaserFadeTarget(1);
            
           // if(i!=index){
                soundObjects[i].setFadeSpeed(0.05);
                soundObjects[i].setTeaserFadeTarget(1);
           // }

        }
    }else{
    
        for(int i=0;i<soundObjects.size();i++){
            //soundObjects[i].setMute(true);
            if(i!=index){
                soundObjects[i].setFadeSpeed(0.05);
                soundObjects[i].setTeaserFadeTarget(0.095);
            }

        }
    }


}


float Soundcontroller::getDirection(float lat1,float lon1,float lat2, float lon2){
        
    float dLat = ofDegToRad(lat2-lat1);
    float dLon = ofDegToRad(lon2-lon1);
    lat1 = ofDegToRad(lat1);
    lat2 = ofDegToRad(lat2);
    
    float y = sin(dLon) * cos(lat2);
    float x = cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(dLon);
    float brng = ofRadToDeg(atan2(y, x));
    
    return brng;
    
}

//--------------------------------------------------------------


float Soundcontroller::getDistance(float lat1,float lon1,float lat2, float lon2){
    
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

//--------------------------------------------------------------
void Soundcontroller::guiEvent(ofxUIEventArgs &e)
{
    
    
   string name= e.widget->getName();
	int kind = e.widget->getKind();
    //cout<<kind<<endl;
    
    if(kind==OFX_UI_WIDGET_ROTARYSLIDER){
        ofxUIRotarySlider *slider =(ofxUIRotarySlider*)e.widget;

        soundObjects[ofToInt(name)].mySound.setPosition(slider->getScaledValue());
    }

    
    if(!e.widget->getName().compare("POSITION"))
    {
        //ofxUIButton *button = (ofxUIButton *) e.widget;
        //   loadUrl();
        //cout<<"button"<<endl;
        
        ofxUIRotarySlider *slider =(ofxUIRotarySlider*)e.widget;
      //  mySound.setPosition(slider->getScaledValue());
        
        
    }

    
    
    
    if(!e.widget->getName().compare("Zoom"))
    {
       
        ofxUISlider *slider =(ofxUISlider*)e.widget;
        for(int i=0;i<soundObjects.size();i++){
            //soundObjects[i].setSound(soundObjects[i].getSoundfile());
            soundObjects[i].setSacleFact(slider->getValue());
        }
    }
    
    
    if(!e.widget->getName().compare("STOPP"))
    {
        cout<<"button!"<<endl;
        
        ofxUIImageButton *button = (ofxUIImageButton *) e.widget;
        bool isDown= button->getValue();
        
        /*   if(isDown){
         for(int i=0;i<numberOfSounds;i++){
         if( soundPoints[i].closest){
         cout<<soundPoints[i].isplaying<<endl;
         if(soundPoints[i].isplaying){
         //                   sounds[i].stop();
         soundPoints[i].isplaying=false;
         cout<<"sounds "<<i<<" stopped"<<endl;
         }else{
         //                 sounds[i].play();
         soundPoints[i].isplaying=true;
         cout<<"sounds "<<i<<" start"<<endl;
         
         }
         }
         }
         }*/
        
        
        /*
         ofxUIToggle *toggle = (ofxUIToggle *) e.widget;
         bool val = toggle->getValue();
         
         if(val){
         
         for(int i=0;i<SOUNDSSIZE;i++){
         if( soundPoints[i].closest){
         sounds[i].stop();
         cout<<"sounds "<<i<<" stopped"<<endl;
         }
         }
         
         }else {
         for(int i=0;i<SOUNDSSIZE;i++){
         if( soundPoints[i].closest){
         sounds[i].play();
         cout<<"sounds "<<i<<" started"<<endl;
         }
         }
         
         }*/
    }
    
    
}

