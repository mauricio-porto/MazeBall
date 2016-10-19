#define DELAY 100

/**
 * Inicialmente vamos usar Serial1 (18 e 19) para o shield bluetooth
 * e Serial (0 e 1) para monitoraçao/depuraçao
 */

void setup() {
  Serial.begin(115200); // Pins 0 (RX) and 1 (TX)
  Serial1.begin(9600); // Pins 19 (RX) and 18 (TX), Serial2 on 17 and 16, Serial3 on 15 and 14
}

void loop() {
  if (Serial1.available() > 0) {
    char c = Serial1.read();
    if (c == 't') { // Move top
      // Do something
      Serial.println("Veio t");
      goto skip;
    }
    if (c == 'b') { // Move bottom
      // Do something
      Serial.println("Veio b");
      goto skip;
    }
    if (c == 'l') { // Move left
      // Do something
      Serial.println("Veio l");
      goto skip;
    }
    if (c == 'r') { // Move right
      // Do something
      Serial.println("Veio r");
      goto skip;
    }
  }
  
skip:
  delay(DELAY);
}
