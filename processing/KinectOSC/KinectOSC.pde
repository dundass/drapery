
/*
read depth in 8 vertical strip sums and send over osc
*/

import KinectPV2.KJoint;
import KinectPV2.*;
import netP5.*;
import oscP5.*;

KinectPV2 kinect;

//Distance Threashold
int maxD = 4500; // 4.5mx
int minD = 0;  //  50cm

int maxVerticalSum = 9999999;

int[] sums = new int[8];
float[] averages = new float[8];
float[] differences = new float[8];

float maxDifference = 0;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(512, 424);

  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);

  kinect.init();
  
  maxVerticalSum = maxD * height * (width / 8);
  
  oscP5 = new OscP5(this, 3002);
  myRemoteLocation = new NetAddress("127.0.0.1", 3001);

}

void draw() {
  background(0);

  image(kinect.getDepthImage(), 0, 0);
  
  //obtain the raw depth data in integers from [0 - 4500]
  int [] rawData = kinect.getRawDepthData();
  
  for(int i = 0; i < sums.length; i++) sums[i] = 0;
  
  int sumsIdx = 0, dataIdx = 0;
  
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      sumsIdx = x / (width / 8);
      dataIdx = (y * width) + x;
      sums[sumsIdx] += rawData[dataIdx];
    }
  }
  
  OscMessage relMessage = new OscMessage("/relative");
  OscMessage absMessage = new OscMessage("/absolute");
  
  for(int i = 0; i < sums.length; i++) {
    float newAverage = map((float)sums[i] / maxVerticalSum, 0, 1, 0.05, 0.4);
    differences[i] = abs(averages[i] - newAverage) * 10;
    averages[i] = newAverage;
    absMessage.add(averages[i]);
    relMessage.add(differences[i]);
  }
  
  oscP5.send(absMessage, myRemoteLocation);
  oscP5.send(relMessage, myRemoteLocation);
  
  if(frameCount > 10 && differences[0] > maxDifference) maxDifference = differences[0];
  
  println(differences[0] + "\t" + maxDifference);
  
}


void keyPressed() {
  if (key == '1') {
    minD += 10;
    println("Change min: "+minD);
  }
}
