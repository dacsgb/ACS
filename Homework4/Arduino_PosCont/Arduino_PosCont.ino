int Drive = 5;
int Dir = 4;
int EnA = 3;
int EnB = 2;
float Pi = 3.1415;

volatile long CT = 0;
float Sp = 5;
float Sp_deriv = 0;
float Est0 = 0;
float Est1 = 0;
float Est_dot = 0;
float U = 6;
float Vmax = 12;
int dt = 10;
float K[2] = {45.0, 1.0};

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  attachInterrupt(digitalPinToInterrupt(EnA), CtA, CHANGE);
  attachInterrupt(digitalPinToInterrupt(EnA), CtB, CHANGE);
}

void loop() {
  delay(dt);
  Est1 = Measure();
  Est_dot = Deriv(Est1, Est0);
  Est0 = Est1;
  Sp = SetPoint();
  Sp_deriv = SetPoint_deriv();
  U = Controller(Sp, 0, Est1, Est_dot);
  Actuate(U);

  Serial.print(Est1);
  Serial.print("\t");
  Serial.println(Est_dot);
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
