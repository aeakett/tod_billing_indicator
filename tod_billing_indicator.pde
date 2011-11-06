#include <Time.h> // from http://www.arduino.cc/playground/Code/Time

#define TIME_MSG_LEN  11   // time sync to PC is HEADER followed by unix time_t as ten ascii digits
#define TIME_HEADER  'T'   // Header tag for serial time sync message
#define TIME_REQUEST  7    // ASCII bell character requests a time sync message 

// T1262347200  //noon Jan 1 2010

#define GREEN_PIN  2
#define YELLOW_PIN 4
#define RED_PIN    7

// stuff for time functions
#define SECS_PER_MIN  60
#define SECS_PER_HOUR 3600
#define SECS_PER_DAY  86400

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
      red();
   }
   else if (second() < 40) {
      yellow();
   }
   else {
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

bool isWeekend() {
   if (weekday()==1 || weekday()==7) {
      return true;
   } else {
      return false;
   }
}

bool isChristmas() {
   if (month()==12 && day()==25) {
      return true;
   } else {
      return false;
   }
}

bool isBoxingDay() {
   if (month()==12 && day()==26) {
      return true;
   } else {
      return false;
   }
}

bool isThanksgiving() {
   if (month()==10 && getNthOccOfDayInMonth(2,2,10) == day()) {
      return true;
   } else {
      return false;
   }
}

bool isLabourDay() {
   if (month()==9 && getNthOccOfDayInMonth(1,2,9) == day()) {
      return true;
   } else {
      return false;
   }
}

bool isCivicHoliday() {
   if (month()==8 && getNthOccOfDayInMonth(1,2,8) == day()) {
      return true;
   } else {
      return false;
   }
}

bool isCanadaDay() {
   if (month()==7 && day()==1) {
      return true;
   } else {
      return false;
   }
}

bool isVictoriaDay() {
   return false;
}

bool isGoodFriday() {
   return false;
}

bool isFamilyDay() {
   if (month()==2 && getNthOccOfDayInMonth(3,2,2) == day()) {
      return true;
   } else {
      return false;
   }
}

bool isNewYearsDay() {
   if (month()==1 && day()==1) {
      return true;
   } else {
      return false;
   }
}

int getNthOccOfDayInMonth(int nthOccurrence, int theDayOfWeek, int theMonth) {
   int theDayInMonth=0;
   if(theDayOfWeek < day(createDateTime(year(),theMonth,1,0,0,0))){
      theDayInMonth = 1 + nthOccurrence*7  + (theDayOfWeek - day(createDateTime(year(),theMonth,1,0,0,0))) % 7;
   } else {
      theDayInMonth = 1 + (nthOccurrence-1)*7  + (theDayOfWeek - dayOfWeek(createDateTime(year(),theMonth,1,0,0,0))) % 7;
   }
   //If the result is greater than days in month or less than 1, return -1
   if(theDayInMonth > daysInMonth(year(), theMonth) || theDayInMonth < 1){
      return -1;
   } else {
      return theDayInMonth;
   }
}

int daysInMonth (int yr, int mnth) {
   int monthDays[]={31,28,31,30,31,30,31,31,30,31,30,31};
   
   if (mnth == 2) {
      if (isLeapYear(yr)) {return 29;} else {return 28;}
   } else {
      return monthDays[mnth-1];
   }
}

bool isLeapYear(int y) {
   if ((1970+y)%4 == 0 && ( (1970+y)%100 == 0 || !((1970+y)%400 == 0))) {
      return true;
   } else {
      return false;
   }
}

time_t createDateTime (int yr, int mnth, int dy, int hr, int mn, int sec) {
   int monthDays[]={31,28,31,30,31,30,31,31,30,31,30,31};
   
   // year can be given as full four digit year or two digts (2010 or 10 for 2010);  
   // it is converted to years since 1970
   if( yr > 99) {
      yr = yr - 1970;
   } else {
      yr += 30;
   }
   
   int i;
   time_t seconds;
   
   // seconds from 1970 till 1 jan 00:00:00 of the given year
   seconds= yr*(SECS_PER_DAY * 365);
   for (i = 0; i < yr; i++) {
      if (isLeapYear(i)) {
         seconds += SECS_PER_DAY;   // add extra days for leap years
      }
   }
   
   // add days for this year, months start from 1
   for (i = 1; i < mnth; i++) {
      if ( (i == 2) && isLeapYear(yr)) { 
         seconds += SECS_PER_DAY * 29;
      } else {
         seconds += SECS_PER_DAY * monthDays[i-1];  //monthDay array starts from 0
      }
   }
   seconds+= (dy-1) * SECS_PER_DAY;
   seconds+= hr * SECS_PER_HOUR;
   seconds+= mn * SECS_PER_MIN;
   seconds+= sec;
}
