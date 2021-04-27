#include <Arduino.h>
#include <PID.h>

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
  pid.setGains(1,2,0);
  pid.setSampling(10);
  pid.setSetpoint(2);
}

void loop() {
  pid.run(true);
  pid.printCt();
}

