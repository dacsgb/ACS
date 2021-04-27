#ifndef PID_H
#define PID_H

#include <Arduino.h>

class PID{
    private:
        // Controller Variables
        float estimates [2] = {0.0,0.0};
        float setpoint [2] = {0.0,0.0};
        float derivatives [2] = {0.0,0.0};
        float gains [3] = {0.0,0.0,0.0};
        float u = 0;
        float du = 0;
        float dt = 20;
        double baud;
        const float pi = 3.1415;

        // System Varaibles
        volatile long CT = 0;
        float Vmax = 12;
        float ratio = float(2*pi)/float(1216);
        const int drive_pin = 5;
        const int dirrection_pin = 4;
        const int EnA = 3;
        const int EnB = 2;
        
        // Controller Functions
        void setup(int baud_rate);
        void measure();
        void derivative();
        void reindex();
        void controller();
        void actuate();


    public:
        // Setup Controller
        PID(int baud_rate);
        void setup();
        int EncoderA();
        int EncoderB();

        // Controller Functions
        void setGains(float Kp, float Kd, float Ki);
        void setSampling(int dt);
        void setSetpoint(float sp);
        void run(bool state);
        void CtA();
        void CtB();
        void printDebug();

        // Reporting and Debugging functions
        void report();
};

PID::PID(int baud_rate){
    baud = baud_rate;
}

void PID::setup(){
    Serial.begin(baud);
    Serial.println("Controller Initiated");
}

void PID::measure(){
    estimates[1] =  ratio*float(CT);
}

void PID::derivative(){
    derivatives[0] = (estimates[1] - estimates[0])/(float(dt)/1000.0);
    derivatives[1] = (setpoint[1] - setpoint[0])/(float(dt)/1000.0);
}

void PID::reindex(){
    estimates[0] = estimates[1];
    setpoint[0] = setpoint[1];
}

void PID::controller(){
    u = gains[0]*(setpoint[1] - estimates[1]) + gains[1]*(derivatives[1]-derivatives[0]);
    if (abs(u) <= Vmax){
      du += gains[2]*(setpoint[1] - estimates[1])*(float(dt)/1000.0);
    }
    u += du;
    u = max(min(u,Vmax),-Vmax);
}

void PID::actuate(){
    int dirrection = (-u/abs(u) > 0 ) ? 1 : 0;
    int drive = min(255, 255 * (abs(u) / Vmax));
    digitalWrite(dirrection_pin, dirrection);
    analogWrite(drive_pin, drive);
}

void PID::CtA(){
    bool EnA_status = digitalRead(EnA);
    bool EnB_status = digitalRead(EnB);
    if (EnB_status == LOW) {
        if (EnA_status == HIGH) {
            CT --;
        }
        else {
            CT++;
        }
    }
    else {
        if (EnA_status == HIGH) {
            CT++;
        }
        else {
            CT--;
        }
    }
}

void PID::CtB(){
    bool EnA_status = digitalRead(EnA);
    bool EnB_status = digitalRead(EnB);
    if (EnA_status == LOW){
        if (EnB_status == HIGH){
            CT ++;
        }
        else{
            CT--;
        }
    }
    else{
        if (EnB_status == HIGH){
            CT--;
        }
        else{
            CT++;
        }
    }
}

// Public Methods
int PID::EncoderA(){
    return EnA;
}

int PID::EncoderB(){
    return EnB;
}

void PID::setGains(float Kp, float Kd, float Ki){
    gains[0] = Kp;
    gains[1] = Kd;
    gains[2] = Ki;
}

void PID::setSampling(int sampling_time){
    dt = sampling_time;
}

void PID::setSetpoint(float sp){
    setpoint[1] = sp;
}

void PID::run(bool state){
    if (state == true){
        delay(dt);
        measure();
        derivative();
        controller();
        actuate();
        reindex();
    }
    else{
      digitalWrite(dirrection_pin, 0);
      analogWrite(drive_pin, 0);
    }
}

void PID::printDebug(){
  Serial.print("Current Position: ");
  Serial.print(estimates[1]);
  Serial.print(" [rad]\t");
  Serial.print("Current Velocity: ");
  Serial.print(derivatives[0]);
  Serial.print(" [rad/s]\t");
  Serial.print("Current Control: ");
  Serial.print(u);
  Serial.println(" [V]");
}

void PID::report(){
  Serial.print("Current Position: ");
  Serial.print(estimates[1]);
  Serial.print(" [rad]\t");
  Serial.print("Current Velocity: ");
  Serial.print(derivatives[1]);
  Serial.println(" [rad/s]");
}

#endif
