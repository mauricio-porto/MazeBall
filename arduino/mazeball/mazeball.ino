/**
 * Algoritmo
 *
 * Se ha comando,
 *   se comando de girar
 *     gira no eixo e sentido desejado
 *     inicia contagem de tempo girando no eixo
 *   se comando de parar
 *     para ambos os eixos
 * senao,
 *   se esta movendo algum eixo
 *     faz tomada de tempo atual
 *     se esta movendo ha mais tempo que o maximo
 *       para o movimento
 *
 */


// define how many cycles to a full rotation
#define CYCLES_PER_ROTATION 512

#define MAX_TIME_MOVING 2000   // 2 seconds

unsigned long moveTimeX = 0L;
unsigned long moveTimeY = 0L;
unsigned long currentTime = 0L;

boolean movingX = false;
boolean movingY = false;
boolean clockwiseX;
boolean clockwiseY;

int stpXPins[] = {8,9,10,11};
int stpYPins[] = {2,3,4,5};

int xPhase = 0;
int yPhase = 0;


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
  if (Serial1.available() > 0) {
    char c = Serial1.read();
    // Detect X axis movement
    if(c == 'l') { // Move left
      movingX = true;
      clockwiseX = false;
    }
    if(c == 'r') { // Move right
      movingX = true;
      clockwiseX = true;
    }
    // Detect Y axis movement
    if(c == 't') { // Move top
      movingY = true;
      clockwiseY = true;
    }
    if(c == 'b') { // Move bottom
      movingY = true;
      clockwiseY = false;
    }
    if(c == 's') {
      phaseSelect(stpXPins, 8); // Stop X movement
      phaseSelect(stpYPins, 8); // Stop Y movement
      movingX = movingY = false;
      moveTimeX = moveTimeY = 0;
    }
  } else {
    currentTime = millis();
    if(movingX && (currentTime - moveTimeX) > MAX_TIME_MOVING) {
      phaseSelect(stpXPins, 8); // Stop X movement
      movingX = false;
      moveTimeX = 0;
    }
    if(movingY && (currentTime - moveTimeY) > MAX_TIME_MOVING) {
      phaseSelect(stpYPins, 8); // Stop X movement
      movingY = false;
      moveTimeY = 0;
    }
  }
  if(movingX) {
    if(clockwiseX) {
      phaseSelect(stpXPins, xPhase);
    } else {
      phaseSelect(stpXPins, 7 - xPhase);
    }
    ++xPhase %= 8;
    if(moveTimeX == 0) {
      moveTimeX = millis();
    }
  }
  if(movingY) {
    if(clockwiseY) {
      phaseSelect(stpYPins, yPhase);
    } else {
      phaseSelect(stpYPins, 7 - yPhase);
    }
    ++yPhase %= 8;
    if(moveTimeY == 0) {
      moveTimeY = millis();
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


