//*********************************************************************************
// this is designed to work with arduino patch, ballmaze06.pde
//*********************************************************************************
// based on Android+Processing+Bluetooth code
// from http://webdelcire.com/wordpress/archives/1045
// and
// Accelerometer code by Antoine Vianey
// http://code.google.com/p/processing/source/browse/trunk/processing/android/examples/Sensors/Accelerometer/AccelerometerManager.java?r=7743
// 
// Made with Processing 2.0 and Android 2.3

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import java.util.ArrayList;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Method;
 
private static final int REQUEST_ENABLE_BT = 3;
ArrayList devices;
BluetoothAdapter adapter;
BluetoothDevice device;
BluetoothSocket socket;
InputStream ins;
OutputStream ons;
boolean registered = false;
PFont f1;
PFont f2;
int state;
String error;
byte thisByte;
byte lastByte;

AccelerometerManager accel;
float ax, ay, az;

int mode = 0;  // 0=phone, 1=wired controller, 2=body controller
int lastmode;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
BroadcastReceiver receptor = new BroadcastReceiver() {
    public void onReceive(Context context, Intent intent) {
        println("onReceive");
        String action = intent.getAction();
 
        if (BluetoothDevice.ACTION_FOUND.equals(action)) {
            BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
            println(device.getName() + " " + device.getAddress());
            devices.add(device);
        
        } else if (BluetoothAdapter.ACTION_DISCOVERY_STARTED.equals(action)) {
          state = 0;
          println("Search begins");
          
        } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
          state = 1;
          println("Search ends");
        }
    }
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  frameRate(25);
  f1 = createFont("Arial",20,true);
  f2 = createFont("Arial",15,true);
  stroke(255);
  
  accel = new AccelerometerManager(this);
  orientation(PORTRAIT);
  smooth();
  //noLoop();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void draw() {
  switch(state) {
    case 0: //------------------------------------------------------
      listdevices("LOOKING devices", color(255, 0, 0));
      break;
      
    case 1: //------------------------------------------------------
      listdevices("CHOOSE device", color(0, 255, 0));
      break;
      
    case 2: //------------------------------------------------------
      connecteddevice();
      break;
      
    case 3: //------------------------------------------------------
      readMode();        // check if arduino has sent a mode update
      drawButtons();
      //displayValues();
      drawBall();
      sendData();
      break;
      
    case 4: //------------------------------------------------------
      sampleError();
      break;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public void resume() {
  if (accel != null) {
    accel.resume();
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
public void pause() {
  if (accel != null) {
    accel.pause();
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public void shakeEvent(float force) {
  println("shake : " + force);
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public void accelerationEvent(float x, float y, float z) {
//  println("acceleration: " + x + ", " + y + ", " + z);
  ax = x;
  ay = y;
  az = z;

  //redraw();
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void onStart() {
  
  super.onStart();
  println("onStart");
  adapter = BluetoothAdapter.getDefaultAdapter();
  if (adapter != null) {
    if (!adapter.isEnabled()) {
        Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
        startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
    } else {
      begins();
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void onStop() {
  
  println("onStop");
  /*
  if(registered) {
    unregisterReceiver(receptor);
  }
  */
 
  if(socket != null) {
    try {
      socket.close();
      
    } catch(IOException ex) {
      println(ex);
    }
  }
  super.onStop();
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void onActivityResult (int requestCode, int resultCode, Intent data) {
  
  println("onActivityResult");
  if(resultCode == RESULT_OK) {
    println("RESULT_OK");
    begins();
    
  } else {
    println("RESULT_CANCELED");
    state = 4;
    error = "No bluetooth is enabled";
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void mouseReleased() {
  
  switch(state) {
    case 0:
      /*
      if(registered)
      {
        adapter.cancelDiscovery();
      }
      */
      break;
    case 1:
      checkSelected();
      break;
    case 3:
      checkButton();
      if (mode != lastmode) {
        sendMode();
        lastmode = mode;
      }
      break;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void begins() {
  
    devices = new ArrayList();
    /*
    registerReceiver(receptor, new IntentFilter(BluetoothDevice.ACTION_FOUND));
    registerReceiver(receptor, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_STARTED));
    registerReceiver(receptor, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED));
    registered = true;
    adapter.startDiscovery();
    */
    for (BluetoothDevice device : adapter.getBondedDevices()) {
      devices.add(device);
    }
    state = 1;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void listdevices(String thisText, color c) {
  
  background(0);
  textFont(f1);
  fill(c);
  text(thisText,0, 20);
  
  if(devices != null) {
    
    for(int indice = 0; indice < devices.size(); indice++) {
      BluetoothDevice device = (BluetoothDevice) devices.get(indice);
      fill(255,255,0);
      int position = 50 + (indice * 55);
      
      if(device.getName() != null) {
        text(device.getName(),0, position);
      }
      
      fill(180,180,255);
      text(device.getAddress(),0, position + 20);
      fill(255);
      line(0, position + 30, 319, position + 30);
    }
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void checkSelected() {
  
  int selected = (mouseY - 50) / 55;
  if(selected < devices.size()) {     
    device = (BluetoothDevice) devices.get(selected);     
    println(device.getName());     
    state = 2;   
  } 
} 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
void connecteddevice() {   
  
  try {     
    socket = device.createRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"));
    /*     
      Method m = device.getClass().getMethod("createRfcommSocket", new Class[] { int.class });     
      socket = (BluetoothSocket) m.invoke(device, 1);             
    */     
    socket.connect();     
    ins = socket.getInputStream();     
    ons = socket.getOutputStream();     
    state = 3;
    
  } catch(Exception ex) {     
    state = 4;     
    error = ex.toString();     
    println(error);   
  } 
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
void readMode() {
  // read Mode from arduino if available
  try {
    if (ins.available() > 0) {
      mode = (byte)ins.read();
    }
    
  } catch(Exception ex) {
    state = 4;
    error = ex.toString();
    println(error);
  }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
void sendMode() {
  // this is called from mouseReleased()
  // send mode to arduino
  try {
    ons.write(254);
    ons.write(mode);
    
  } catch(Exception ex) {
    state = 4;
    error = ex.toString();
    println(error);
  }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
void sendData() {
  // this happens every loop
  // send ax+ay to arduino
  try {
    ons.write(255);             // header byte
    ons.write(int((ax+10)*5));  // converts -10 to 10, to 0 to 100
    ons.write(int((ay+10)*5));  // converts -10 to 10, to 0 to 100
    
  } catch(Exception ex) {
    state = 4;
    error = ex.toString();
    println(error);
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void checkButton() {
  
  if (mouseY > 30 && mouseY < 110) {
    if(mouseX > width/24 && mouseX < width*7/24) {
      mode = 0;
    } else if (mouseX > width*3/8 && mouseX < width*5/8) {
      mode = 1;
    } else if (mouseX > width*17/24 && mouseX < width*23/24) {
      mode = 2;
    }
  }
/* 
  if (mouseY > height - 100 && mouseY < height - 20) {
    if(mouseX > width/24 && mouseX < width*7/24) {
      // reconnect button
      state = 1;
    }
  }    
*/

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void sampleError() {
  
  background(255, 0, 0);
  fill(255, 255, 0);
  textFont(f2);
  textAlign(CENTER);
  translate(width / 2, height / 2);
  rotate(3 * PI / 2);
  text(error, 0, 0);
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void drawButtons() {

  background(0);
  
  // draw Mode buttons
  textFont(f1);
  textAlign(CENTER);
  
  // Mode 0 (left button) -------------
  if (mode == 0) {
    stroke(200);
    fill(255, 0, 0);
  } else {
    stroke(200);
    fill(50);
  }
  rect(width/24, 30, width/4, 80, 20);
  fill(200);
  text("wired",(width/6), 75);


  // Mode 1 (middle button) -------------
  if (mode == 1) {
    stroke(200);
    fill(255, 0, 0);
  } else {
    stroke(200);
    fill(50);
  }
  rect(width*3/8, 30, width/4, 80, 20);
  fill(200);
  text("body",(width/2), 75);

  
  // Mode 2 (right button) -------------
  if (mode == 2) {
    stroke(200);
    fill(255, 0, 0);
  } else {
    stroke(200);
    fill(50);
  }
  rect(width*17/24, 30, width/4, 80, 20);
  fill(200);
  text("phone",(width*5/6), 75);  
/*  
  // Reconnect button -------------
  stroke(200);
  fill(50);
  rect(width/24, height - 100, width/4, 80, 20);
  fill(200);
  text("reconnect",(width/6), height - 55);
*/  
  
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void displayValues() {
  
  textFont(f1);
  textAlign(LEFT);
  fill(255);
  
  text("x: " + nf(ax, 1, 2), 20, 160); 
  text("y: " + nf(ay, 1, 2), 20, 190); 
  text("mode: " + mode, 20, 220);
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void drawBall() {
  stroke(200);
  fill(50);
  ellipse(map(ax, 10, -10, 0, width), map(ay, -10, 10, 0, height), 40, 40);
  
}
