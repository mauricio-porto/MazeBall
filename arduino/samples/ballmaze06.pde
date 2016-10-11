//*********************************************************************************
// this is designed to work with Processing patch, ballmaze02.pde
//*********************************************************************************

int tableXpin = 0;                    // analog input for the table accelerometer X
int tableYpin = 1;                    // analog input for the table accelerometer Y
int controllerXpin = 2;               // analog input for the controller accelerometer X
int controllerYpin = 3;               // analog input for the controller accelerometer Y
int motorXpinA = 4;                   // motor controller A1
int motorXpinB = 2;                   // motor controller B1
int motorXpinPWM = 3;                 // motor controller PWM1
int motorYpinA = 7;                   // motor controller A2
int motorYpinB = 6;                   // motor controller B2
int motorYpinPWM = 5;                 // motor controller PWM2
int modeButtonpin = 18;               // (analog 4) used as Digital in to read mode switch (wired, body, phone)
int controllerswitchpin = 19;         // (analog 5) used as Digital in to read controller switch (motor on/off)
int ledpin =  13;                     // LED connected to digital pin 13 for signaling which controller is being used
int sonarXpins[6] = {0,0,10,0,11,0};  // pin 2 -> digital 10  // pin 4 -> digital 11
int sonarYpins[6] = {0,0,8,0,9,0};    // pin 2 -> digital 8  // pin 4 -> digital 9

int controllerXflat = 333;                                 // value returned by controller accelerometer when flat
int controllerXrange = 90;                                 // range of acceptable accelerometer values either side of flat
int controllerXmin = controllerXflat - controllerXrange;   // calc min allowable accelerometer value
int controllerXmax = controllerXflat + controllerXrange;   // calc max allowable accelerometer value

int controllerYflat = 355;                                 // value returned by controller accelerometer when flat
int controllerYrange = 90;                                 // range of acceptable accelerometer values either side of flat
int controllerYmin = controllerYflat - controllerYrange;   // calc min allowable accelerometer value
int controllerYmax = controllerYflat + controllerYrange;   // calc max allowable accelerometer value

int tableXflat = 519;                                      // value returned by table accelerometer when flat
int tableXrange = 30;                                      // range of acceptable accelerometer values either side of flat
int tableXmin = tableXflat - tableXrange;                  // calc min allowable accelerometer value
int tableXmax = tableXflat + tableXrange;                  // calc max allowable accelerometer value

int tableYflat = 492;                                      // value returned by table accelerometer when flat
int tableYrange = 30;                                      // range of acceptable accelerometer values either side of flat
int tableYmin = tableYflat - tableYrange;                  // calc min allowable accelerometer value
int tableYmax = tableYflat + tableYrange;                  // calc max allowable accelerometer value

int controllerX;                    // value returned by controller accelerometer X
int controllerY;                    // value returned by controller accelerometer Y

const int numReadings = 4;                // number of readings stored for smoothing
int index = 0;                      // keeps track of position in the readings array
int targetX[numReadings];           // map controller to range expected from table tilt accelerometer
int targetXtotal;
float targetXaverage;

int targetY[numReadings];           // map controller to range expected from table tilt accelerometer
int targetYtotal;
float targetYaverage;

int inputX;                         // used to calculate the target tilt values
int inputXmin;
int inputXmax;
int inputY;
int inputYmin;
int inputYmax;

int tableX[numReadings];            // value returned by table tilt accelerometer X
int tableXtotal;
float tableXaverage;

int tableY[numReadings];            // value returned by table tilt accelerometer Y
int tableYtotal;
float tableYaverage;

//correction = Kp * error + Kd * (error - prevError) + kI * (sum of errors)
float Kp = 10;        // PID Position gain
float Ki = 0;         // PID Integral gain
float Kd = 20;        // PID Derivative gain

int Kp_significand ;    // integer value received from Processing, since it's more complicated to send floats
int Kp_exponent;        // exponent used with Kp_significand to calculate Kp
int Ki_significand ;    // integer value received from Processing, since it's more complicated to send floats
int Ki_exponent = 1;    // exponent used with Ki_significand to calculate Ki
int Kd_significand ;    // integer value received from Processing, since it's more complicated to send floats
int Kd_exponent = 1;    // exponent used with Kd_significand to calculate Kd

float errorX;            // error used in PID calcs
float errorY;            // error used in PID calcs
float msX;               // motor speed calculated in PID calcs
float msY;               // motor speed calculated in PID calcs
int motorspeedX;         // actual motor speed sent to motor
int motorspeedY;         // actual motor speed sent to motor

float lasterrorX = 0;    // previous error for the derivitive term
float lasterrorY = 0;    // previous error for the derivitive term
float sumerrorX = 0;     // and the sum of the errors for the integral term
float sumerrorY = 0;     // and the sum of the errors for the integral term
float iMax = 100.0;      // integral term max so it doesn't get out of control
float iMin = -100.0;     // integral term min so it doesn't get out of control

long duration;              // duration of the sonar reflection (uS)

int distanceX;                                      // distance measured by sonar in X direction (front-back)
int distanceXflat = 145;                             // distance to person when table is flat in X direction (cm)
int distanceXrange = 45;                            // range of expected distances moved either side on centre (cm)
int distanceXmin = distanceXflat - distanceXrange;  // calc min expected distance
int distanceXmax = distanceXflat + distanceXrange;  // calc max expected distance
int distanceXprev = distanceXflat;                  // previous X distance reading

int distanceY;                                      // distance measured by sonar in Y direction (left-right)
int distanceYflat = 75;                             // distance to person when table is flat in Y direction (cm)
int distanceYrange = 45;                            // range of expected distances moved either side on centre (cm)
int distanceYmin = distanceYflat - distanceYrange;  // calc min expected distance
int distanceYmax = distanceYflat + distanceYrange;  // calc max expected distance
int distanceYprev = distanceYflat;                  // previous Y distance reading

long personGoneX;                                   // records the time at which the sonar registers a person leaving in X direction
long personGoneY;                                   // records the time at which the sonar registers a person leaving in Y direction

int ax;                                             // phone accerometer X value received (range is 0 to 100)
int axflat = 50;                                    // flat = 0 on phone but is mapped to 50 for serial comms
int axrange = 35;                                   // range of expected values either side of flat
int axmin = axflat - axrange;                       // minimum allowable phone accel X value
int axmax = axflat + axrange;                       // maximum allowable phone accel X value

int ay;                                             // phone accerometer Y value received (range is 0 to 100)
int ayflat = 50;                                    // flat = 0 on phone but is mapped to 50 for serial comms
int ayrange = 35;                                   // range of expected values either side of flat
int aymin = ayflat - ayrange;                       // minimum allowable phone accel Y value
int aymax = ayflat + ayrange;                       // maximum allowable phone accel Y value

int prevmodeButtonReading = HIGH;      // the previous reading from the mode button input pin

int mode;                  // 0=wired, 1=body, 2=phone
int lastMode;              // previous mode

boolean LEDstate;
long LEDblinkTime;

boolean phoneConnected;    // used to signal loss of serial connection
long serialTimer;          // used to detect loss of serial connection
int header;                // for serial comms

//===========================================================================================================================
void setup() {
  Serial.begin(115200);
  
  pinMode(motorXpinA, OUTPUT);
  pinMode(motorXpinB, OUTPUT);
  pinMode(motorXpinPWM, OUTPUT);
  pinMode(motorYpinA, OUTPUT);
  pinMode(motorYpinB, OUTPUT);
  pinMode(motorYpinPWM, OUTPUT);
  pinMode(modeButtonpin, INPUT);
  digitalWrite(modeButtonpin, HIGH);     // turn on the built in pull-up resistor
  pinMode(controllerswitchpin, INPUT);
  pinMode(ledpin, OUTPUT); 
  digitalWrite(ledpin, LOW);
  
  // Maxbotix sonar setup
  //setting the 4 pin to low will not allow the sensor to range unless I tell it to.  This prevents bad readings from waves bouncing around.
  pinMode(sonarXpins[4],OUTPUT); 
  digitalWrite(sonarXpins[4],LOW);
  pinMode(sonarXpins[2],INPUT);

  pinMode(sonarYpins[4],OUTPUT); 
  digitalWrite(sonarYpins[4],LOW);
  pinMode(sonarYpins[2],INPUT);

  // initialize all the readings to 0: 
  for (int thisReading = 0; thisReading < numReadings; thisReading++) {
    targetX[thisReading] = 0; 
    targetY[thisReading] = 0; 
    tableX[thisReading] = 0; 
    tableY[thisReading] = 0; 
  } 
  
  LEDstate = false;
  mode = 0;    // 0=wired, 1=body, 2=phone
  lastMode = 0;
  phoneConnected = false;
}

//=========================================================================================================================== 
void loop() {

  // check communications with phone ------------------------------------------------------------------------------
  if(Serial.available() > 0){
    phoneConnected = true;
    serialTimer = millis();                          // reset the serial timer
    header = Serial.read();                          // read one byte to check if it's an expected header byte
    
    switch (header) {
      case 255:                                      // header for accel data
        while (Serial.available() < 2 ) {            // wait for 2 bytes to read
          if (millis() > serialTimer + 500L) {       // check if it's taking too long
            phoneConnected = false;                  // if it is, assume there's no phone connection
            break;
          }
        }
        
        if (phoneConnected == true) {                // if the phone is still connected
          ay = Serial.read();                        // read the X accelerometer value
          ax = Serial.read();                        // read the Y accelerometer value
        }
        break;
        
      case 254:                                      // header for mode data
        while (Serial.available() < 1 ) {            // wait for 1 byte to read
          if (millis() > serialTimer + 500L) {       // check if it's taking too long
            phoneConnected = false;                  // if it is, assume there's no phone connection
            break;
          }
        }
        
        if (phoneConnected == true) {                // if the phone is still connected
          mode = Serial.read();                      // read the mode value
        }  
        break;
      
      //default:
        //phoneConnected = false;                      // serial is out of sync, so assume there's no phone connection
        //commented this out because was going out of sync every few seconds, with a '2' instead of '255' as header
    }
  }
  
  if (millis() > serialTimer + 500L) {               // then it's been too long since hearing from the phone
    phoneConnected = false;                          // assume there's no phone connection
  }
  
  if (mode == 2 && phoneConnected == false) {        // if we are in phone mode, and receiving nothing from phone
    mode = 0;      // change to wired mode
  }
    

  // check mode switch on arduino ---------------------------------------------------------------------------------
  int modeButtonReading = digitalRead(modeButtonpin);
  
  if ((modeButtonReading == LOW) && (prevmodeButtonReading == HIGH)) {
    
    mode++;
   
    if (phoneConnected == true) {                    // if communicating successfully with phone
      if (mode > 2) {                                // allow the mode to increment to phone mode
        mode = 0;
      }
      Serial.write(mode);                            // send Mode to phone
      
    } else {                                         // if not, then just alternate between modes 0 & 1
      if (mode > 1) {
        mode = 0;
      }
    }

  }
  prevmodeButtonReading = modeButtonReading;         // to change mode only on first press of key
  
  
  // check to see if mode has changed, either by phone or controller switch ---------------------------------------
  if (mode != lastMode) {
    switch(mode) {
      case(0):  // wired controller  
        // LED off
        LEDstate = false;
     
        // reset smoothing vars for wired controller
        for (int i=0; i<numReadings; i++) {
          targetX[i] = 0;
          targetY[i] = 0;
          tableX[i] = 0;        
          tableY[i] = 0;
        }
        targetXtotal = 0;
        targetYtotal = 0;
        tableXtotal = 0;
        tableYtotal = 0;
        index = 0;
     
        break;
  
      case(1):  // body controller
        // LED on
        LEDstate = true;
        break;
        
      case(2):  // phone controller
        // LED blinking
        LEDstate = false;
        LEDblinkTime = millis();
        break;
    }
    // send to LED
    digitalWrite(ledpin, LEDstate);

    lastMode = mode;
  }
      
  
  // operate in selected mode ----------------------------------------------------------------------------------------
  switch(mode) {
    case(0):
      // use wired accelerometer controller  
      controllerX = analogRead(controllerXpin);     // read the accelerometer X value (0 - 1023)
      controllerY = analogRead(controllerYpin);     // read the accelerometer Y value (0 - 1023)

      // calculate target tilts --------------
      targetXtotal = targetXtotal - targetX[index];
      targetX[index] = map(controllerX, controllerXmin, controllerXmax, tableXmin, tableXmax);// set the target to seek to by mapping the accel values to the range of acceptable accelerometer values  targetXtotal = targetXtotal + targetX[index];
      targetXtotal = targetXtotal + targetX[index];
      targetXaverage = float(targetXtotal) / numReadings;
    
      targetYtotal = targetYtotal - targetY[index];
      targetY[index] = map(controllerY, controllerYmax, controllerYmin, tableYmin, tableYmax);// set the target to seek to by mapping the accel values to the range of acceptable accelerometer values
      targetYtotal = targetYtotal + targetY[index];
      targetYaverage = float(targetYtotal) / numReadings;
    
      Kp = 10;        // PID Position gain
      Ki = 0;         // PID Integral gain
      Kd = 20;        // PID Derivative gain
    
      break;
  
    case(1):
      // read sonar sensors
      digitalWrite(sonarXpins[4],HIGH);
      delayMicroseconds(30);                       //Maxbotix needs pin 4 to be set to HIGH for 20uS to tell it to take a reading
      duration = pulseIn(sonarXpins[2],HIGH);
      digitalWrite(sonarXpins[4],LOW);             //set it back to LOW so it stops pinging.  Don't want interference
      distanceX = int(duration / 58);
        
      delay(10);
    
      digitalWrite(sonarYpins[4],HIGH);
      delayMicroseconds(30);                       //Maxbotix needs pin 4 to be set to HIGH for 20uS to tell it to take a reading
      duration = pulseIn(sonarYpins[2],HIGH);
      digitalWrite(sonarYpins[4],LOW);             //set it back to LOW so it stops pinging.  Don't want interference
      distanceY = int(duration / 58);
    
      // check if person has left the area
      if (distanceX > (2*distanceXflat)){
        if (personGoneX == 0) {
          personGoneX = millis();
        } else if (millis() - personGoneX > 1000) {
          distanceX = distanceXflat;
          distanceXprev = distanceXflat;
        }
      } else {
        personGoneX = 0;
      }
       
      if (distanceY > (2*distanceYflat)){
        if (personGoneY == 0) {
          personGoneY = millis();
        } else if (millis() - personGoneY > 1000) {
          distanceY = distanceYflat;
          distanceYprev = distanceYflat;
        }
      } else {
        personGoneY = 0;
      }
    
      // check for spurious signals
      // this also works so that the table will sit flat until someone
      // moves to within 10cm of the centre point, and then it will follow them
      if abs(distanceX - distanceXprev > 10) {
        distanceX = distanceXprev;
      } else {
        distanceXprev = distanceX;
      }
      
      if abs(distanceY - distanceYprev > 10) {
        distanceY = distanceYprev;
      } else {
        distanceYprev = distanceY;
      }

      targetXaverage = float(map(distanceX, distanceXmin, distanceXmax, tableXmin, tableXmax));
      targetYaverage = float(map(distanceY, distanceYmin, distanceYmax, tableYmin, tableYmax));
      
      Kp = 5;        // PID Position gain
      Ki = 0;        // PID Integral gain
      Kd = 6;        // PID Derivative gain

      break;
      
    case(2):
      // blink LED
      if (millis() > LEDblinkTime + 250) {
        LEDstate = !LEDstate;
        digitalWrite(ledpin, LEDstate);
        LEDblinkTime = millis();
      }
      
      // phone accelerometer values were received earlier 
      targetXaverage = float(map(ax, axmin, axmax, tableXmin, tableXmax));
      targetYaverage = float(map(ay, aymin, aymax, tableYmin, tableYmax));
      
      Kp = 10;        // PID Position gain
      Ki = 0;         // PID Integral gain
      Kd = 20;        // PID Derivative gain
    
      break;
  }
  
  // adjust the board  ----------------------------------------------------------------------------------------------
  tableXtotal = tableXtotal - tableX[index];
  tableX[index] = analogRead(tableXpin);                   // read the table accelerometer value
  tableXtotal = tableXtotal + tableX[index];
  tableXaverage = float(tableXtotal) / numReadings;  

  tableYtotal = tableYtotal - tableY[index];
  tableY[index] = analogRead(tableYpin);                   // read the table accelerometer value
  tableYtotal = tableYtotal + tableY[index];
  tableYaverage = float(tableYtotal) / numReadings;  
  
  // advance to the next position in the array:
  index++;
  if(index == numReadings) index = 0;
  
  // calculate the motor speed required --------------------------------------------------------------
  errorX = tableXaverage - targetXaverage;                 // find the error term of current position - target
  errorY = tableYaverage - targetYaverage;                 // find the error term of current position - target
  
  // generalized PID formula
  //correction = Kp * error + Kd * (error - prevError) + kI * (sum of errors)
  msX = (Kp * errorX) + (Ki * sumerrorX) + (Kd * (errorX - lasterrorX)) ;  // calculate a motor speed for the current conditions
  msY = (Kp * errorY) + (Ki * sumerrorY) + (Kd * (errorY - lasterrorY)) ;  // calculate a motor speed for the current conditions
  
  // set the last and sumerrors for next loop iteration
  lasterrorX = errorX;
  lasterrorY = errorY;

  sumerrorX += errorX;
  sumerrorY += errorY;  
  
  //scale the sum for the integral term
  if(sumerrorX > iMax){
    sumerrorX = iMax;
  }
  else if(sumerrorX < iMin){
    sumerrorX = iMin;
  }

  if(sumerrorY > iMax){
    sumerrorY = iMax;
  }
  else if(sumerrorY < iMin){
    sumerrorY = iMin;
  }

  int direction_X;                       //determine the direction to go in since the motor controller expects positive values
  if(msX > 0){
    // motor backwards
    digitalWrite(motorXpinA, LOW);
    digitalWrite(motorXpinB, HIGH);
  }
  if(msX < 0){
    // motor forwards
    digitalWrite(motorXpinA, HIGH);
    digitalWrite(motorXpinB, LOW);
    msX = -1 * msX;
  }

  int direction_Y;                       //determine the direction to go in since the motor controller expects positive values
  if(msY > 0){
    // motor backwards
    digitalWrite(motorYpinA, LOW);
    digitalWrite(motorYpinB, HIGH);
  }
  if(msY < 0){
    // motor forwards
    digitalWrite(motorYpinA, HIGH);
    digitalWrite(motorYpinB, LOW);
    msY = -1 * msY;
  }
  
  // map the result to the max speed the controller will expect 
  //(not sure if this is a good idea)
  motorspeedX = constrain(int(msX+0.5),0,255);    // adding 0.5 to get rounding instead of truncation
  motorspeedY = constrain(int(msY+0.5),0,255);    // adding 0.5 to get rounding instead of truncation

  if (digitalRead(controllerswitchpin) == LOW) {  // provide option to turn motor off
    // ON  
    analogWrite(motorXpinPWM, motorspeedX);
    analogWrite(motorYpinPWM, motorspeedY);
    
  } else {
    // OFF
    analogWrite(motorXpinPWM, 0);
    analogWrite(motorYpinPWM, 0);
  }

}
