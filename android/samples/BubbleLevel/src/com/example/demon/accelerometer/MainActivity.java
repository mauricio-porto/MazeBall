package com.example.demon.accelerometer;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.graphics.Point;
import android.graphics.Typeface;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.view.Display;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends Activity {

    Accelerometer accelerometer;
    TextView tvText, dimen_Horizontal, dimen_Vertical, text_Horizontal, text_Vertical;

    float x_degrees, y_degrees, valuesAccel_X, valuesAccel_Y;
    double norm_of_degrees;
    SensorManager sensorManager;
    Sensor sensorLinAccel;
    Sensor sensorGravity;
    Sensor sensorAccel;
    MyTask myTask;
    Typeface type;
    Timer timer;

    String font = "fonts/RobotoCondensed_LightItalic.ttf";
    StringBuilder sb = new StringBuilder();
    Button button_Pause, button_Start;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        setViews();
        setSensors();
        setFonts();
        setTextSize();

        button_Pause.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                set_Pause();
            }
        });
        button_Start.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                set_Start();
            }
        });
    }


    private void setTextSize() {

        int textSize = getTextSize();

        dimen_Vertical.setTextSize(textSize);
        dimen_Horizontal.setTextSize(textSize);
        text_Vertical.setTextSize(textSize);
        text_Horizontal.setTextSize(textSize);
        button_Start.setTextSize(textSize);
        button_Pause.setTextSize(textSize);
    }

    private int getTextSize() {
        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x;
        int height = size.y;
        return height/30;
    }

    private void setFonts() {
        type = Typeface.createFromAsset(getAssets(), font);
        dimen_Vertical.setTypeface(type);
        dimen_Horizontal.setTypeface(type);
        text_Vertical.setTypeface(type);
        text_Horizontal.setTypeface(type);
        button_Start.setTypeface(type);
        button_Pause.setTypeface(type);
        tvText.setTypeface(type);
    }

    private void setSensors() {
        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        sensorAccel = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        sensorLinAccel = sensorManager.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION);
        sensorGravity = sensorManager.getDefaultSensor(Sensor.TYPE_GRAVITY);

        sensorManager.registerListener(listener, sensorAccel,SensorManager.SENSOR_DELAY_FASTEST);
        sensorManager.registerListener(listener, sensorLinAccel,SensorManager.SENSOR_DELAY_FASTEST);
        sensorManager.registerListener(listener, sensorGravity,SensorManager.SENSOR_DELAY_FASTEST);
    }

    private void setViews() {
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        dimen_Horizontal = (TextView) findViewById(R.id.dimen_Horizontal);
        dimen_Vertical = (TextView) findViewById(R.id.dimen_Vertical);
        text_Horizontal = (TextView) findViewById(R.id.text_Horizontal);
        text_Vertical = (TextView) findViewById(R.id.text_Vertical);
        tvText = (TextView) findViewById(R.id.tvText);
        button_Pause = (Button) findViewById(R.id.button_Pause);
        button_Start = (Button) findViewById(R.id.button_Start);
        accelerometer = (Accelerometer) findViewById(R.id.accelerometer);
    }

    private void set_Pause() {
            timer.cancel();
    }

    private void set_Start() {
            if(timer!=null){timer.cancel();}
            timer = new Timer();
            myTask = new MyTask();
            timer.schedule(myTask, 0, 10);
    }

    String format(float values[]) {
        return String.format("%1$.1f\t\t%2$.1f\t\t%3$.1f", values[0], values[1], values[2]);
    }

    void showInfo() {
        sb.setLength(0);
        sb.append("Accelerometer: " + format(valuesAccel))
          .append("\n\nAccel motion: " + format(valuesAccelMotion))
          .append("\nAccel gravity : " + format(valuesAccelGravity))
          .append("\n\nLin accel : " + format(valuesLinAccel))
          .append("\nGravity : " + format(valuesGravity));
        tvText.setText(sb);
    }

    private void setDegrees() {
        norm_of_degrees = Math.sqrt(Math.pow(valuesAccel[0], 2) +
                Math.pow(valuesAccel[1], 2) +
                Math.pow(valuesAccel[2], 2));

        // Normalize the accelerometer vector
        valuesAccel_X = (float) (valuesAccel[0] / norm_of_degrees);
        valuesAccel_Y = (float) (valuesAccel[1] / norm_of_degrees);

        x_degrees = (float)(90 - Math.toDegrees(Math.acos(valuesAccel_X)));
        y_degrees = (float)(90 - Math.toDegrees(Math.acos(valuesAccel_Y)));
    };

    float[] valuesAccel = new float[3];
    float[] valuesAccelMotion = new float[3];
    float[] valuesAccelGravity = new float[3];
    float[] valuesLinAccel = new float[3];
    float[] valuesGravity = new float[3];

    SensorEventListener listener = new SensorEventListener() {

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {

        }

        @Override
        public void onSensorChanged(SensorEvent event) {
            switch (event.sensor.getType()) {
                case Sensor.TYPE_ACCELEROMETER:
                    for (int i = 0; i < 3; i++) {
                        valuesAccel[i] = event.values[i];
                        valuesAccelGravity[i] = (float) (0.1 * event.values[i] + 0.9 * valuesAccelGravity[i]);
                        valuesAccelMotion[i] = event.values[i]
                                - valuesAccelGravity[i];
                    }
                    break;
                case Sensor.TYPE_LINEAR_ACCELERATION:
                    for (int i = 0; i < 3; i++) {
                        valuesLinAccel[i] = event.values[i];
                    }
                    break;
                case Sensor.TYPE_GRAVITY:
                    for (int i = 0; i < 3; i++) {
                        valuesGravity[i] = event.values[i];
                    }
                    break;
            }
        }
    };

    class MyTask extends TimerTask{

        @Override
        public void run() {

          setDegrees();

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    showInfo();
                    accelerometer.setXY(valuesAccel[0], valuesAccel[1]);
                    accelerometer.onXY_Update(accelerometer.getXdimen(), accelerometer.getYdimen());

                    dimen_Horizontal.setText(String.valueOf(x_degrees + " " + '\u00b0'));
                    dimen_Vertical.setText(String.valueOf(y_degrees + " " + '\u00b0'));
                }
            });
        }
    }
}
