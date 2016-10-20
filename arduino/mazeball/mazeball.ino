#define DELAY 100

/**
 * Inicialmente vamos usar Serial1 (18 e 19) para o shield bluetooth
 * e Serial (0 e 1) para monitoraçao/depuraçao
 */

int stpXPins[] = {8,9,10,11};
int stpYPins[] = {2,3,4,5};

void setup() {
  Serial1.begin(9600); // Pins 19 (RX) and 18 (TX), Serial2 on 17 and 16, Serial3 on 15 and 14

  pinMode(stpXPins[0], OUTPUT); 
  pinMode(stpXPins[1], OUTPUT); 
  pinMode(stpXPins[2], OUTPUT); 
  pinMode(stpXPins[3], OUTPUT); 

  pinMode(stpYPins[0], OUTPUT); 
  pinMode(stpYPins[1], OUTPUT); 
  pinMode(stpYPins[2], OUTPUT); 
  pinMode(stpYPins[3], OUTPUT); 

}

void loop() {

  int xPhase = 0;
  int yPhase = 0;

  if (Serial1.available() > 0) {
    char c = Serial1.read();
    // Detect Y axis movement
    if (c == 't') { // Move top
      phaseSelect(stpYPins, yPhase);
      ++yPhase %= 8;
      goto skip;
    }
    if (c == 'b') { // Move bottom
      phaseSelect(stpYPins, 7 - yPhase);
      ++yPhase %= 8;
      goto skip;
    }

    // Detect X axis movement
    if (c == 'l') { // Move left
      phaseSelect(stpXPins, 7 - xPhase);
      ++xPhase %= 8;
      goto skip;
    }
    if (c == 'r') { // Move right
      phaseSelect(stpXPins, xPhase);
      ++xPhase %= 8;
      goto skip;
    }
  }
  phaseSelect(stpXPins, 8); // Stop X movement
  phaseSelect(stpYPins, 8); // Stop Y movement

skip:
  delay(DELAY);
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

