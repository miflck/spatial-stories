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


//--------------------------------------------------------------
void Soundcontroller::setup(){
    
    ofRegisterTouchEvents(this); // this will enable our circle class to listen to the mouse events.
    ofRegisterURLNotification(this);

    
    nobel.loadFont("TradeGothicLTCom.ttf", 25,true,true);
    

    displaystring="";
    zoomval=800;
    
    //-------- GUI ---------
    gui = new ofxUICanvas(0,0,ofGetWidth(),500);
    gui->setFont("TradeGothicLTCom.ttf");                     //This loads a new font and sets the GUI font

    ofColor pad = ofColor(0,255,0,0);
    ofColor backgroundcolor = ofColor(255,0,0);
    ofColor outlinecolor = ofColor(255,0,0,200);
    ofColor paddingColor = ofColor(0,0,0,150);
    
    ofColor highlightcolor = ofColor(0,0,0,200);
    ofColor paddingoutline = ofColor(0,0,0,255);
    
    gui->setFontSize(OFX_UI_FONT_LARGE, 30);            //These call are optional, but if you want to resize the LARGE, MEDIUM, and SMALL fonts, here is how to do it.
    gui->setFontSize(OFX_UI_FONT_MEDIUM, 20);
    gui->setFontSize(OFX_UI_FONT_SMALL, 15);
    
    gui->setDrawWidgetPadding(false);
    gui->setDrawBack(true);
    gui->setDrawPadding(true);
    gui->setDrawPaddingOutline(false);
    gui->setDrawOutline(true);

     gui->setColorBack(backgroundcolor);
     gui->setColorOutline(outlinecolor);
     gui->setColorFillHighlight(highlightcolor);
     gui->setColorOutlineHighlight(highlightcolor);
     gui->setColorPadded(pad);
    gui->setColorOutline(ofColor(0,0,0,255));
    
    gui->setColorPaddedOutline(paddingoutline);
    gui->setGlobalSpacerHeight(50);
    gui->setGlobalSliderHeight(50);
    gui->setGlobalButtonDimension(50);
    gui->setColorFill(ofColor(255,200));
    

    
    gui->addLabel("LOAD TOURS", OFX_UI_FONT_LARGE);
    gui->addToggle("LOAD AUDIO", false, 44, 44);

    vector<string> names;
    gui->setWidgetFontSize(OFX_UI_FONT_MEDIUM);
    ddl = gui->addDropDownList("TOUR LIST", names);
    ofxUIRectangle* r=ddl->getRect();
    r->setHeight(50);
    ddl->setAllowMultiple(false);
  
    gui->autoSizeToFitWidgets();
    ofAddListener(gui->newGUIEvent, this, &Soundcontroller::guiEvent);
 
    
    gui->setVisible(true);
    
    //INIT Listener
    listenerPos.set(devicePosition);
    listenerDir.set(0,-1,0);
    
    
    
    // ------- Soundobjects ----------------
    
    //Temporary Position Object for loading SoundObjets
    ofVec2f tempPos(ofGetWidth()/2,0);
    soundObjects.clear(); //clear array
  
    loadTourlist();
   // loadUrlwithPath("hello");
    //  loadUrl(); // load points
    
  //  loadAudioUrlwithPath("hallo.m4a");
    


    

    ofAddListener(SoundObject::clickedInsideGlobal , this, &Soundcontroller::onMouseInAnyCircle);//listening to this event will enable us to get events from any instance of the circle class as this event is static (shared by all instances of the same class).

    ofAddListener(SoundObject::stepOverThreshold , this, &Soundcontroller::onSteppedOverAnyThreshold);//listening to this event will enable us to get events from any instance of the circle class as this event is static (shared by all instances of the same class).

   ofAddListener(SoundObject::stepOutThreshold , this, &Soundcontroller::onSteppedOutAnyThreshold);//listening to this event will enable us to get events from any instance of the circle class as this event is static (shared by all instances of the same class).

    
    
    //-------- Graphics ---------
    compassImg.loadImage("dir.png");
    compassImg.setAnchorPoint(compassImg.width/2, compassImg.height);
    
    cout<<"finished setup soundcontroller"<<endl;
    
    bLoadAudio=false;
    
    
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
    

    ofEnableAlphaBlending();
    for (int i=0;i<soundObjects.size();i++){
     soundObjects[i].draw();
    }
    
    ofDisableAlphaBlending();

   // gui->draw();
    
  

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


//--------------------------------------------------------------
void Soundcontroller::setPoints(ofxJSONElement _result){
    ofxJSONElement points =_result;
    
  soundObjects.clear();
      
    cout<<"there are "<<points.size()<<" sounds"<<endl;
    
    //check for Audiofiles:
    for(int i=0; i<points.size(); i++)
    {
        string filepath = points[i]["filepath"].asString();
        vector <string> rawfile= ofSplitString(filepath, "/");
        
        cout<<rawfile.size()<<endl;
        
        string file = ofSplitString(rawfile.back(), "_")[0];
        string ending = ofSplitString(rawfile.back(), ".")[1];

        string corefilename=file+"."+ending;
        string teaserfilename = file+"_teaser."+ending;

        ofDirectory coredir(ofxiPhoneGetDocumentsDirectory() +corefilename);
        ofDirectory teaserdir(ofxiPhoneGetDocumentsDirectory() +teaserfilename);
        
        
        

        cout<<"i want "<<corefilename<<" "<<teaserfilename<<endl;
        string path;
        
        for(int i=0;i<rawfile.size()-1;i++){
            path+=rawfile[i]+"/";
        }
        cout<<"my Path "<<path<<endl;
        
        string corefilepath;
        string teaserfilepath;
        corefilepath=path+file+"."+ending;
        teaserfilepath=path+file+"_teaser."+ending;
        
        
        if(!coredir.exists() && corefilename!="nofile" && bLoadAudio)loadAudioUrlwithPath(corefilepath,corefilename);
        if(!teaserdir.exists() && teaserfilename!="nofile" && bLoadAudio)loadAudioUrlwithPath(teaserfilepath,teaserfilename);
    }
    
    
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
        cout<<"try create soundobject"<<endl;
        
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
        
     }
}


//--------------------------------------------------------------

void Soundcontroller::loadUrlwithPath(string _path){
    
    std:: string url = "http://spatialstories.michaelflueckiger.ch/frontend/getPoints?mypath="+_path;
    
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
        
        cout<<"Dir " <<ofxiPhoneGetDocumentsDirectory()<<endl;
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



void Soundcontroller::urlResponse(ofHttpResponse & response) {
    
    cout<<"------------------URL Response----------"<<endl;
    cout<<response.request.name<<endl;
    cout<<response.request.url<<endl;

    if (response.status==200 && response.request.name == "async_req") {
        cout<<"loaded"<<endl;
       // cout<<response.data<<endl;
        //img.loadImage(response.data);
       // loading = false;
    } else {
        cout <<"--ASYNC ERROR------------- status"<< response.status << " " << response.error << endl;
    //    if (response.status != -1) loading = false;
    }
}

//--------------------------------------------------------------

void Soundcontroller::loadAudioUrlwithPath(string _path, string _filename){
    
    cout<<"loading audiofile"<<endl;
    
  //  std:: string url = "http://spatialstories.michaelflueckiger.ch/media/upload/audio/"+_path;
    
  //  int id = ofLoadURLAsync("http://spatialstories.michaelflueckiger.ch/media/upload/audio/"+_path,
  //                          "async_req");
   // string DDoSTarget = "http://spatialstories.michaelflueckiger.ch/media/upload/audio/"+_path;
    string DDoSTarget = "http://spatialstories.michaelflueckiger.ch/"+_path;
    
    
    
    
    
 //  string URL                 = '[http://www.w3schools.com/xml/note.xml';](http://www.w3schools.com/xml/note.xml';)
    
  //  ofLoadURLAsync(DDoSTarget, "async_req");
    ofSaveURLAsync(DDoSTarget, ofxiPhoneGetDocumentsDirectory()+_filename);

    
    
/*    bool parsingSuccessful=result.open(url);
    cout <<"parsing audio"<<parsingSuccessful<<endl;
    
    
    if (!response.open(url)) {
        cout  << "Failed to parse Audio No Response…" << endl;
        ofFile file(ofxiPhoneGetDocumentsDirectory() +_path,ofFile::ReadOnly);
        ofBuffer buff = file.readToBuffer();
        result=buff.getText();
        setPoints(result);
        
    }
    
    
    if ( parsingSuccessful )
    {
        cout << result.getRawString() << endl;
        
      //  cout<<ofxiPhoneGetDocumentsDirectory()<<endl;
      //  ofFile file(ofxiPhoneGetDocumentsDirectory() +"mySavedPoints.txt",ofFile::WriteOnly);
   //     file << response.getRawString() << endl;
     //   file.close();
        
        //setPoints(result);
        for(int i=0;i<soundObjects.size();i++){
            //soundObjects[i].setSound(soundObjects[i].getSoundfile());
          //  soundObjects[i].setup();
            
        }
    }
    else
    {
        cout  << "Failed to parse JSON. Try local" << endl;
    //    bool parsingSuccessful=result.open(ofxiPhoneGetDocumentsDirectory()+"mySavedPoints.txt");
      //  setPoints(result);
        for(int i=0;i<soundObjects.size();i++){
        //    soundObjects[i].setSound(soundObjects[i].getSoundfile());
         //   soundObjects[i].setup();
        }
        
    }
 */
}




//--------------------------------------------------------------

void Soundcontroller::loadTourlist(){
    
    std:: string url = "http://spatialstories.michaelflueckiger.ch/frontend/getTours";
    
    bool parsingSuccessful=result.open(url);
    cout <<"parsing "<<parsingSuccessful<<endl;
    
    
    if (!response.open(url)) {
        cout  << "Failed to parse JSON\n No Response…" << endl;
    }
    
    
    if ( parsingSuccessful )
    {
       cout << result.getRawString() << endl;
        ofxJSONElement listelements =result;
        cout<<"there are "<<listelements.size()<<" tours"<<endl;
        for(int i=0; i<listelements.size(); i++)
        {
        string url = listelements[i]["url"].asString();
        ddl->addToggle(url);
        }
    }
    else
    {
    cout  << "Failed to parse JSON. Try local" << endl;
    }
}





//--------------------------------------------------------------
void Soundcontroller::onMouseInAnyCircle(int & e){
    displaystring="clicked in"+ofToString(e);
    cout<<"clicked in"<<e<<endl;
    
}


//--------------------------------------------------------------
void Soundcontroller::onSteppedOverAnyThreshold(int & e){
    cout<<"someone stepped over the threshold of"<<e<<endl;
    displaystring="stepped over "+ofToString(e);
    
    
    soundObjects[e].setFadeSpeed(0.05);    
    for(int i=0;i<soundObjects.size();i++){
        //soundObjects[i].setMute(true);
    }

    
}






//--------------------------------------------------------------
void Soundcontroller::onSteppedOutAnyThreshold(int & e){
    cout<<"someone stepped over the threshold of"<<e<<endl;
     soundObjects[e].setFadeSpeed(0.05);
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
        soundObjects[i].setFadeSpeed(0.05);
        soundObjects[i].setTeaserFadeTarget(1);
        }
    }else{
    
        for(int i=0;i<soundObjects.size();i++){
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
void Soundcontroller::touchDown(ofTouchEventArgs & touch){
    
    if(touch.id==2){
        gui->toggleVisible();
    }
    
    
    
}

//--------------------------------------------------------------
void Soundcontroller::touchMoved(ofTouchEventArgs & touch){
    
    
    
}

//--------------------------------------------------------------
void Soundcontroller::touchUp(ofTouchEventArgs & touch){
    
    
}

//--------------------------------------------------------------
void Soundcontroller::touchDoubleTap(ofTouchEventArgs & touch){
    }

//--------------------------------------------------------------
void Soundcontroller::touchCancelled(ofTouchEventArgs & touch){
    
}


void Soundcontroller::mouseMoved(ofMouseEventArgs & args){}
void Soundcontroller::mouseDragged(ofMouseEventArgs & args){}
void Soundcontroller::mousePressed(ofMouseEventArgs & args){}
void Soundcontroller::mouseReleased(ofMouseEventArgs & args){}


//--------------------------------------------------------------
void Soundcontroller::guiEvent(ofxUIEventArgs &e)
{
    
    
    
   string name= e.widget->getName();
	int kind = e.widget->getKind();
    cout<<kind<<endl;
    
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

    
    if(name == "SHOW ACTIVE")
    {
        cout<<"show active"<<endl;
        ofxUIToggle *toggle = (ofxUIToggle *) e.widget;
        ddl->setShowCurrentSelected(toggle->getValue());
    }
    
    
    
    if(name =="TOUR LIST")
    {
        ofxUIDropDownList *ddlist = (ofxUIDropDownList *) e.widget;
        vector<ofxUIWidget *> &selected = ddlist->getSelected();
        for(int i = 0; i < selected.size(); i++)
        {
            cout << "SELECTED: " << selected[i]->getName() << endl;
            loadUrlwithPath(selected[i]->getName());
        }
    }

    
    if(name == "LOAD AUDIO")
    {
        ofxUILabelToggle *toggle = (ofxUILabelToggle *) e.widget;
        bLoadAudio = toggle->getValue();
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

