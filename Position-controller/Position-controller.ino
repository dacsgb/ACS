#include <Arduino.h>
#include "PID.h"

// Create Controller Object
PID pid(9600);

void CountA(){
  pid.CtA();
}
void CountB(){
  pid.CtB();
}

void setup() {
  attachInterrupt(digitalPinToInterrupt(pid.EncoderA()), CountA, CHANGE);
  attachInterrupt(digitalPinToInterrupt(pid.EncoderB()), CountB, CHANGE);
  pid.setup();
  pid.run(false);
  pid.setGains(2.25,0.003,1);

}

void loop() {
    pid.setSetpoint(1);
    pid.run(true);
    pid.printDebug();
}
