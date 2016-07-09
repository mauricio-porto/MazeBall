const int tolerance = 1023 * 0.05;
const int center = 1023 / 2;
const int downThreshold = center - tolerance;
const int upThreshold = center + tolerance;

const int sensorX = A0;
const int sensorY = A1;

// define how many cycles to a full rotation
#define CYCLES_PER_ROTATION 512

int stpXPins[] = {8,9,10,11};

int stpYPins[] = {2,3,4,5};

void setup() 
{
  Serial.begin(9600);
  pinMode(stpXPins[0], OUTPUT); 
  pinMode(stpXPins[1], OUTPUT); 
  pinMode(stpXPins[2], OUTPUT); 
  pinMode(stpXPins[3], OUTPUT); 

  pinMode(stpYPins[0], OUTPUT); 
  pinMode(stpYPins[1], OUTPUT); 
  pinMode(stpYPins[2], OUTPUT); 
  pinMode(stpYPins[3], OUTPUT); 

  balance();
}

void loop() {
  delay(10);
}

void balance() {

  boolean needCenterX = true;
  boolean needCenterY = true;

  boolean xClockwise;
  boolean yClockwise;
  int xPhase = 0;
  int yPhase = 0;

  int xPos = analogRead(sensorX);
  if (xPos > upThreshold) {
      Serial.println("Move X clockwise");
      xClockwise = true;
  } else if (xPos < downThreshold) {
      Serial.println("Move X counter clockwise");
      xClockwise = false;
  } else {
    needCenterX = false;
  }

  int yPos = analogRead(sensorY);
  if (yPos > upThreshold) {
      Serial.println("Move Y clockwise");
      yClockwise = true;
  } else if (yPos < downThreshold) {
      Serial.println("Move Y counter clockwise");
      yClockwise = false;
  } else {
    needCenterY = false;
  }
 
  while (needCenterX || needCenterY) {

    if (needCenterX) {
      int xPos = analogRead(sensorX);
      if (xPos < upThreshold && xPos > downThreshold) {
        needCenterX = false;
        Serial.println("X is centered");
        phaseSelect(stpXPins, 8); // Stop X movement
      } else {
        if (xClockwise) {
          phaseSelect(stpXPins, xPhase);
        } else {
          phaseSelect(stpXPins, 7 - xPhase);
        }
        ++xPhase %= 8;
      }
    }

    if (needCenterY) {
      int yPos = analogRead(sensorY);
      if (yPos < upThreshold && yPos > downThreshold) {
        needCenterY = false;
        Serial.println("Y is centered");
        phaseSelect(stpYPins, 8); // Stop Y movement
      } else {
        if (yClockwise) {
          phaseSelect(stpYPins, yPhase);
        } else {
          phaseSelect(stpYPins, 7 - yPhase);
        }
        ++yPhase %= 8;
      }
    }
  }
}

void phaseSelect(int *pins, int phase) {
  switch(phase) {
     case 0:
       digitalWrite(pins[0], LOW); 
       digitalWrite(pins[1], LOW);
       digitalWrite(pins[2], LOW);
       digitalWrite(pins[3], HIGH);
       break; 
     case 1:
       digitalWrite(pins[0], LOW); 
       digitalWrite(pins[1], LOW);
       digitalWrite(pins[2], HIGH);
       digitalWrite(pins[3], HIGH);
       break; 
     case 2:
       digitalWrite(pins[0], LOW); 
       digitalWrite(pins[1], LOW);
       digitalWrite(pins[2], HIGH);
       digitalWrite(pins[3], LOW);
       break; 
     case 3:
       digitalWrite(pins[0], LOW); 
       digitalWrite(pins[1], HIGH);
       digitalWrite(pins[2], HIGH);
       digitalWrite(pins[3], LOW);
       break; 
     case 4:
       digitalWrite(pins[0], LOW); 
       digitalWrite(pins[1], HIGH);
       digitalWrite(pins[2], LOW);
       digitalWrite(pins[3], LOW);
       break; 
     case 5:
       digitalWrite(pins[0], HIGH); 
       digitalWrite(pins[1], HIGH);
       digitalWrite(pins[2], LOW);
       digitalWrite(pins[3], LOW);
       break; 
     case 6:
       digitalWrite(pins[0], HIGH); 
       digitalWrite(pins[1], LOW);
       digitalWrite(pins[2], LOW);
       digitalWrite(pins[3], LOW);
       break; 
     case 7:
       digitalWrite(pins[0], HIGH); 
       digitalWrite(pins[1], LOW);
       digitalWrite(pins[2], LOW);
       digitalWrite(pins[3], HIGH);
       break; 
     default:
       digitalWrite(pins[0], LOW); 
       digitalWrite(pins[1], LOW);
       digitalWrite(pins[2], LOW);
       digitalWrite(pins[3], LOW);
       break; 
  }
  delay(1);
}
