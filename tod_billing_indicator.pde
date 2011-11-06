#include <Time.h>

#define TIME_MSG_LEN  11   // time sync to PC is HEADER followed by unix time_t as ten ascii digits
#define TIME_HEADER  'T'   // Header tag for serial time sync message
#define TIME_REQUEST  7    // ASCII bell character requests a time sync message 

// T1262347200  //noon Jan 1 2010

#define GREEN_PIN  2
#define YELLOW_PIN 4
#define RED_PIN    7

void setup() {
   Serial.begin(9600);
   setSyncProvider(requestSync);  //set function to call when sync required
   needTime();
   pinMode(GREEN_PIN, OUTPUT);
   pinMode(YELLOW_PIN, OUTPUT);
   pinMode(RED_PIN, OUTPUT);
}

void loop() {
   if(Serial.available()) {
      processSyncMessage();
   }
   if(timeStatus()!= timeNotSet) {
      lightsCameraAction();
   }
   delay(1000);
}

void lightsCameraAction() {
   if (second() < 20) {
      //Serial.print("red");
      //Serial.println();
      red();
   }
   else if (second() < 40) {
      //Serial.print("yellow");
      //Serial.println();
      yellow();
   }
   else {
      //Serial.print("green");
      //Serial.println();
      green();
   }
}

void red() {
   digitalWrite(YELLOW_PIN, LOW);
   digitalWrite(GREEN_PIN, LOW);
   digitalWrite(RED_PIN, HIGH);
}

void yellow() {
   digitalWrite(RED_PIN, LOW);
   digitalWrite(GREEN_PIN, LOW);
   digitalWrite(YELLOW_PIN, HIGH);
}

void green() {
   digitalWrite(RED_PIN, LOW);
   digitalWrite(YELLOW_PIN, LOW);
   digitalWrite(GREEN_PIN, HIGH);
}

void needTime() {
   Serial.println("Waiting for sync message");
   digitalWrite(GREEN_PIN, HIGH);
   digitalWrite(YELLOW_PIN, HIGH);
   digitalWrite(RED_PIN, HIGH);
}

void processSyncMessage() {
   // if time sync available from serial port, update time and return true
   while(Serial.available() >= TIME_MSG_LEN ){ // time message consists of a header and ten ascii digits
      char c = Serial.read();
      Serial.print(c);
      if( c == TIME_HEADER ) {
         time_t pctime = 0;
         for(int i=0; i < TIME_MSG_LEN -1; i++) {
            c = Serial.read();
            if( c >= '0' && c <= '9') {
               pctime = (10 * pctime) + (c - '0'); // convert digits to a number
            }
         }   
         setTime(pctime);   // Sync Arduino clock to the time received on the serial port
      }
   }
}

time_t requestSync()
{
   Serial.print(TIME_REQUEST,BYTE);  
   return 0; // the time will be sent later in response to serial mesg
}
