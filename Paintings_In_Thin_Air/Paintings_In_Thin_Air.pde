/*

 "Paintings In thin Air"
 By: Justin Johnson
 
 Sketch based off the OpenWeather API: https://openweathermap.org/
 Distributed under the CC license (CC BY-SA 4.0)
 
 Particles will flow based on:
 Wind Speed and Direction - Brush Stroke & Speed
 Atmospheric Pressure - less pressure/higher elevation = thinner particles
 Temp - Brush Color
 */

JSONObject wthr;
PFont font;

//global parameters
float windAngle, windSpeed, airPressure, currentTemp;

WindParticleSystem p_sys;

void setup() {
  size(400, 400);
  
  //global properties
  pixelDensity(displayDensity());
  blendMode(DIFFERENCE);
  font = createFont("SIMPLIFICA Typeface.ttf", 50);
  textAlign(CENTER, CENTER);
  colorMode(HSB, 360, 100, 100);

  //Just for demonstration, we'll use Los Angeles with Imperial Units
  String url = "http://api.openweathermap.org/data/2.5/weather?q=Los Angeles";
  //***REPLACE with your own! After signing up for a free account***
  String id = "&APPID=REPLACE-WITH-YOUR-OWN-ID"; //****Copy and paste the id here: starting after the = sign.****
  String unit = "&units=imperial";

  url+=id;
  url+=unit;

  wthr = loadJSONObject(url);
  //Extract parameters:
  //View parameters used at https://openweathermap.org/current#parameter

  JSONObject mainInfo = wthr.getJSONObject("main"); //for pressure
  JSONObject windInfo = wthr.getJSONObject("wind");

  printArray(windInfo);
  println(windInfo.getFloat("speed"));

  windAngle = windInfo.getFloat("deg");
  windSpeed = windInfo.getFloat("speed");
  airPressure = mainInfo.getFloat("pressure"); //*pressure at sea level
  currentTemp = mainInfo.getFloat("temp");

  p_sys = new WindParticleSystem();

  background(0);
  textFont(font);
  text(wthr.getString("name"), width/2, height/2);
}

void draw() {
  if (frameCount%10 == 0) {
    p_sys.addNew();
  }
  p_sys.run(windSpeed/200, windAngle, airPressure/500, currentTemp);
}

class WindParticleSystem {
  ArrayList <WindParticle> windParticles;

  WindParticleSystem() {
    windParticles = new ArrayList<WindParticle>();
  }

  void addNew() {
    windParticles.add(new WindParticle());
  }

  void run(float mag_, float angle_, float pressure_, float temp_) {
    for (WindParticle w : windParticles) {
      //again, in degrees (to fit with the API Response output)!
      w.setForce(mag_, angle_);
      w.weight = pressure_;
      w.tempHue = 180*((150-temp_)/150);
      w.update();
      w.display();
    }

    for (int i = windParticles.size() - 1; i >= 0; i--) {
      if (windParticles.get(i).isDead()) {
        windParticles.remove(i);
      }
    }
  }
}

//Wind particles
class WindParticle {
  PVector position, velocity, acceleration;
  float lifespan, weight, tempHue;
  WindParticle() {
    position = new PVector(random(width*0.2, width*0.8), random(height*0.2, height*0.8));
    velocity = PVector.random2D();
    velocity.mult(random(0.5, 1.5));
    acceleration = new PVector(0, 0);
    lifespan = 1.0;
    weight = 1.0;
    tempHue = 0.0;
  }

  void update() {
    velocity.add(acceleration);
    position.add(velocity);
  }

  void display() {
    stroke(tempHue, 100, 100, floor(calcTransparency()*255));
    strokeWeight(weight);
    point(position.x, position.y);
  }

  //***dir in degrees!***
  void setForce(float magnitude, float dirAngle) {
    PVector dir = PVector.fromAngle(radians(dirAngle));
    acceleration = PVector.mult(dir, magnitude);
  }

  float calcTransparency() {
    float theta = (1.0-lifespan)*TWO_PI;
    return norm(cos(theta), -1, 1);
  }

  boolean isDead() {
    return lifespan <= 0.0;
  }
}
