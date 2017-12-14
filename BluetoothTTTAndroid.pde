/**
 * <p>Ketai Library for Android: http://ketai.org</p>
 *
 * <p>KetaiBluetooth wraps the Android Bluetooth RFCOMM Features:
 * <ul>
 * <li>Enables Bluetooth for sketch through android</li>
 * <li>Provides list of available Devices</li>
 * <li>Enables Discovery</li>
 * <li>Allows writing data to device</li>
 * </ul>
 * <p>Updated: 2012-05-18 Daniel Sauter/j.duran</p>
 */

//required for BT enabling on startup
import android.content.Intent;
import android.os.Bundle;

import ketai.net.bluetooth.*;
import ketai.ui.*;
import ketai.net.*;

import oscP5.*;

KetaiBluetooth bt;
KetaiGesture gesture;
String info = "";
KetaiList klist;
PVector remoteMouse = new PVector();

//******************************
//from TTT3D
int sen = 3;
int div = 3;

Normalize n[] = new Normalize[sen];
MomentumAverage cama[] = new MomentumAverage[sen];
MomentumAverage axyz[] = new MomentumAverage[sen];
float[] nxyz = new float[sen];
int[] ixyz = new int[sen];
//float[] xyz = new float[sen];
String serial = new String();
String serialB = new String();
String serialRes = new String();
String[] serialR = new String[sen];

float w = 256; // board size
boolean[] flip = {
  false, true, false};

int player = 0;
boolean moves[][][][];

PFont font;
//******************************

ArrayList<String> devicesDiscovered = new ArrayList();
boolean isConfiguring = true;
String UIText;

//********************************************************************
// The following code is required to enable bluetooth at startup.
//********************************************************************
void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  bt = new KetaiBluetooth(this);
}

void onActivityResult(int requestCode, int resultCode, Intent data) {
  bt.onActivityResult(requestCode, resultCode, data);
}

//********************************************************************

void setup()
{   
  orientation(LANDSCAPE);
  fullScreen(OPENGL);
  frameRate(25);
  gesture = new KetaiGesture(this);
  background(78, 93, 75);
  stroke(255);
  textSize(24);
  //String[] parts = split(serial, " ");

  //start listening for BT connections
  bt.start();

  UIText = "Aditiya Dwi Putra Sidabutar\n" +
    "24010314130087 \n\n" +
    "d - discover devices\n" +
    "b - make this device discoverable\n" +
    "c - connect to device\n     from discovered list.\n" +
    "p - list paired devices\n" +
    "i - Bluetooth info" + serial;
    
  for(int i = 0; i < sen; i++) {
    n[i] = new Normalize();
    cama[i] = new MomentumAverage(.01);
    axyz[i] = new MomentumAverage(.15);
  }
    
  reset();
}

void draw()
{
  if (isConfiguring)
  {
    ArrayList<String> names;
    background(78, 93, 75);

    //based on last key pressed lets display
    //  appropriately
    if (key == 'i')
      info = getBluetoothInformation();
    else
    {
      if (key == 'p')
      {
        info = "Paired Devices:\n";
        names = bt.getPairedDeviceNames();
      }
      else
      {
        info = "Discovered Devices:\n";
        names = bt.getDiscoveredDeviceNames();
      }

      for (int i=0; i < names.size(); i++)
      {
        info += "["+i+"] "+names.get(i).toString() + "\n";
      }
    }
    text(UIText + "\n\n" + serial + "\n\n" + info, 5, 90);
    drawUI();
  }
  else
  {
    /*
    background(78, 93, 75);
    pushStyle();
    fill(255);
    ellipse(mouseX, mouseY, 20, 20);
    fill(0, 255, 0);
    stroke(0, 255, 0);
    ellipse(remoteMouse.x, remoteMouse.y, 20, 20);    
    popStyle();
    */
    updateSerial();
    drawBoard();
    fill(100, 100, 0, 200);
    text("Aditiya Sidabutar", 5, 0);
    text("24010314130087", 5, 30); 
  }
  
}


//Call back method to manage data received
void onBluetoothDataEvent(String who, byte[] data)
{
  //if (isConfiguring)
    //return;
  serialB += new String(data);
  
  int i;
  char[] charArray = serialB.toCharArray();
  for(i=0;i<serialB.length();i++){
    if(charArray[i] == '\n'){
      serialR = split(serialB, "\n");
      serial = serialRes + serialR[0];
      serialRes = serialR[1];
      serialB = "";
    }
  }
  /*if (serialB.length() > 14){
    serialB = "";
  }*/
}

String getBluetoothInformation()
{
  String btInfo = "Server Running: ";
  btInfo += bt.isStarted() + "\n";
  btInfo += "Discovering: " + bt.isDiscovering() + "\n";
  btInfo += "Device Discoverable: "+bt.isDiscoverable() + "\n";
  btInfo += "\nConnected Devices: \n";

  ArrayList<String> devices = bt.getConnectedDeviceNames();
  for (String device: devices)
  {
    btInfo+= device+"\n";
  }

  return btInfo;
}