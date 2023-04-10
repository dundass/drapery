
/*
read depth in 8 vertical strip averages and send over osc
*/

import KinectPV2.KJoint;
import KinectPV2.*;
import netP5.*;
import oscP5.*;

enum Engine {  // maybe ?
  PureData,
  Supercollider
}

KinectPV2 kinect;

//Distance Threshold
int maxD = 4500; // 4.5mx
int minD = 0;  //  50cm

int maxVerticalSum = 9999999;

final int x_size = 8;
final int y_size = 4;  // TODO - y axis expansion !
final String ip = "127.0.0.1";
final int send_port = 3001; // pure data
//final int send_port = 57120;  // supercollider
final int receive_port = 3002; // to processing

int[] sums = new int[x_size * y_size];
float[] averages = new float[x_size * y_size];
float[] differences = new float[x_size * y_size];

float maxDifference = 0;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(512, 424);

  kinect = new KinectPV2(this);

  kinect.enableDepthImg(true);

  kinect.init();
  
  maxVerticalSum = maxD * (height / y_size) * (width / x_size);
  
  oscP5 = new OscP5(this, receive_port);
  myRemoteLocation = new NetAddress(ip, send_port);
  
  sendIds();

}

void draw() {
  background(0);

  image(kinect.getDepthImage(), 0, 0);
  
  //obtain the raw depth data in integers from [0 - 4500]
  int [] rawData = kinect.getRawDepthData();
  
  // reset the sums
  for(int i = 0; i < sums.length; i++) sums[i] = 0;
  
  // do the sums
  int sumsIdx = 0, dataIdx = 0;
  int block_x_size = width / x_size, block_y_size = height / y_size;
  
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      sumsIdx = (x / block_x_size) + ((y / block_y_size) * x_size);
      dataIdx = (y * width) + x;
      sums[sumsIdx] += rawData[dataIdx];
    }
  }
  
  // send the messages
  OscMessage relMessage = new OscMessage("/relative");
  OscMessage absMessage = new OscMessage("/absolute");
  
  for(int i = 0; i < sums.length; i++) {
    float newAverage = map((float)sums[i] / maxVerticalSum, 0, 1, 0.05, 0.3);
    differences[i] = abs(averages[i] - newAverage) * 10;
    averages[i] = newAverage;
    absMessage.add(averages[i]);
    relMessage.add(differences[i]);
  }
  
  oscP5.send(absMessage, myRemoteLocation);
  oscP5.send(relMessage, myRemoteLocation);
  
  //if(frameCount > 10 && differences[0] > maxDifference) maxDifference = differences[0];
  //println(differences[0] + "\t" + maxDifference);
  
  // draw an overlay
  stroke(255);
  for(int x = 1; x < x_size; x++) line(x * block_x_size, 0, x * block_x_size, height);
  for(int y = 1; y < y_size; y++) line(0, y * block_y_size, width, y * block_y_size);
  
  
}

void mousePressed() {
  sendIds();
}

void keyPressed() {
  if (key == '1') {
    minD += 10;
    println("Change min: "+minD);
  }
}

void sendIds() {
  // send strip/block ids once as a list of normalised floats (for setting pan or other X axis mapping)
  OscMessage idsMessage = new OscMessage("/ids");
  for(int i = 0; i < x_size * y_size; i++) idsMessage.add((float)i / (x_size * y_size));
  oscP5.send(idsMessage, myRemoteLocation);
}
