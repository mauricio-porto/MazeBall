#define DELAY 100

void setup() {
  Serial.begin(9600); // Pins 0 (RX) and 1 (TX)
  Serial1.begin(9600); // Pins 19 (RX) and 18 (TX), Serial2 on 17 and 16, Serial3 on 15 and 14
}

void loop() {
  if (Serial.available() > 0) {
    char c = Serial.read();
    if (c == 't') { // Move top
      // Do something
      goto skip;
    }
    if (c == 'b') { // Move bottom
      // Do something
      goto skip;
    }
    if (c == 'l') { // Move left
      // Do something
      goto skip;
    }
    if (c == 'r') { // Move right
      // Do something
      goto skip;
    }
  }
  
skip:
  delay(DELAY);
}
