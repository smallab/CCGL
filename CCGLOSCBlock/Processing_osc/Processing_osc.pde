import oscP5.*;
import oscP5.osc.*;


// OSC /////////////////////////////////////////////////////////////////////////////////

OscP5 oscP5;
int receiveAtPort;
int sendToPort;
String host;
String oscP5event;

void initOsc() {
        receiveAtPort = 7005;
        sendToPort = 57120;
        host = "localhost";
        oscP5event = "oscEvent";
        oscP5 = new OscP5(this,host,sendToPort,receiveAtPort,oscP5event);
}

void oscEvent(OscIn oscIn) {
        unpackMessage(oscIn);
}

void unpackMessage(OscIn oscIn) {  
   if (oscIn.checkAddrPattern("/cinder/osc/1")) {
       if(oscIn.checkTypetag("i")) {
         int f = oscIn.getInt(0);
         println("you have received a message "+oscIn.getAddrPattern()+"   mCubeSize = "+f);
         bkgd = f;
       }
   }
}

void sendMessage(float sample) {
        OscMessage oscMsg = oscP5.newMsg("/play");
        oscMsg.add(sample);

        oscP5.sendMsg(oscMsg);
}


// VARS, SETUP & DRAW ////////////////////////////////////////////////////////////////

int bkgd = 0;

void setup(){
    size(400, 400);
    frameRate(30);
    initOsc();
}

void draw() {
    background(map(bkgd, 0,100, 0,255));
    sendMessage(norm(mouseX, 0,400));
}
