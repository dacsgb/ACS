// Define Motor Pins
#define Drive = 5;
#define Dir = 4;
#define EnA = 3;
#define EnB = 2;
#define Pi = 3.1415;

// Define Controller Variables
volatile long CT = 0;
float Sp[2] = {0.0,0.0};
float Sp_dot = 0;
float Est[2] = {0.0,0.0};
float Est_dot = 0;
float U = 0;
float Vmax = 12;
int dt = 10;
float K[3] = {45.0, 1.0, 0.0};

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  attachInterrupt(digitalPinToInterrupt(EnA), CtA, CHANGE);
  attachInterrupt(digitalPinToInterrupt(EnA), CtB, CHANGE);
}

void loop() {
  // Sampling time wait
  delay(dt);
  // Store Angle to Variable, take derivative and reindex
  Est[1] = Measure();
  Est_dot = Deriv(Est[1], Est[0]);
  Est[1] = Est[0];
  // Store Setpoint tovariable, take derivative and reindex
  Sp[1] = SetPoint();
  Sp_dot = Deriv(Sp[1],Sp[0]);
  Sp[0] = Sp[1];
  // Compute Controller Input
  U = Controller(Sp[1], Sp_dot, Est[1], Est_dot);
  // Actuate motor
  Actuate(U);
  // Output data to serial monitor
  Report(); 
}

float SetPoint() {
  return 3.14 * sin(5*float(millis()) / 1000);
}
float SetPoint_deriv() {
  return 0;
}
float Measure() {
  return float(CT) * (4 * Pi / 1216); 
}

float Deriv(float e1, float e0) {
  return (e1 - e0) / (float(dt) / 1000);
}

float Controller(float sp, float sp_dot, float est, float est_dot) {
  float u = K[0] * (sp - est) + K[1] * (sp_dot - est_dot) ;
  return u;
}

void Report(){
  Serial.print("Current Position: ");
  Serial.print(Est[1]);
  Serial.print(" [rad]\t");
  Serial.print("Current Velocity: ");
  Serial.print(Est_dot);
  Serial.println(" [rad/s]")
}

void Actuate(float u) {
  int dir = -u / abs(u);
  if (-u / abs(u) > 0) {
    dir = 1;
  }
  else {
    dir = 0;
  }
  int drive = min(255, 255 * (abs(u) / Vmax));
  digitalWrite(Dir, dir);
  analogWrite(Drive, drive);

}

void CtA() {
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


void CtB() {
  bool EnA_status = digitalRead(EnA);
  bool EnB_status = digitalRead(EnB);
  if (EnA_status == LOW) {
    if (EnB_status == HIGH) {
      CT ++;
    }
    else {
      CT--;
    }
  }
  else {
    if (EnB_status == HIGH) {
      CT--;
    }
    else {
      CT++;
    }
  }
}
