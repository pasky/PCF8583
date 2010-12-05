#include <Wire.h> // necessary, or the application won't build properly
#include <stdio.h>
#include <PCF8583.h>
/*****************************************************************************
 *  read/write serial interface to PCF8583 RTC via I2C interface
 *
 *  Arduino analog input 5 - I2C SCL (PCF8583 pin 6)
 *  Arduino analog input 4 - I2C SDA (PCF8583 pin 5)
 *
 *  You can set the type by sending it YYMMddhhmmss;
 *  the semicolon on the end tells it you're done...
 *
 ******************************************************************************/

int correct_address = 0;
PCF8583 p (0xA0);	
volatile int ints = 0;

void timer_handler(void) {
  ints++;
  // clear the interrupt signal
  p.ack_timer();
}


void setup(void){
  Serial.begin(9600);
  Serial.print("booting...");

  attachInterrupt(1, timer_handler, FALLING);

  // get an interrupt every hour at the 20th minute (XXX: Except current hour,
  // when you will get it in t+20minutes).
  p.set_timer(RTC_TIMER_MINS, 20);

  Serial.println(" done");
}


void loop(void){
  if(Serial.available() > 0){
       p.year= (byte) ((Serial.read() - 48) *10 +  (Serial.read() - 48)) + 2000;
       p.month = (byte) ((Serial.read() - 48) *10 +  (Serial.read() - 48));
       p.day = (byte) ((Serial.read() - 48) *10 +  (Serial.read() - 48));
       p.hour  = (byte) ((Serial.read() - 48) *10 +  (Serial.read() - 48));
       p.minute = (byte) ((Serial.read() - 48) *10 +  (Serial.read() - 48));
       p.second = (byte) ((Serial.read() - 48) * 10 + (Serial.read() - 48)); // Use of (byte) type casting and ascii math to achieve result.  

       if(Serial.read() == ';'){
         Serial.println("setting date");
	 p.set_time();
       }
  }


  p.get_time();
  char time[50];
  sprintf(time, "[%d] %02d/%02d/%02d %02d:%02d:%02d", ints,
	  p.year, p.month, p.day, p.hour, p.minute, p.second);
  Serial.println(time);

  delay(3000);
}





