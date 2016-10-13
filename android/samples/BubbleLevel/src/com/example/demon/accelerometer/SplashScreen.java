package com.example.demon.accelerometer;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Point;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.view.Display;
import android.widget.TextView;

/**
 * Created by Demon on 10.06.2015.
 */
public class SplashScreen extends Activity{

    String font = "fonts/RobotoCondensed_LightItalic.ttf";
    String stringBuilder;
    TextView textView;
    int textSize;

    // Splash screen timer
    private static int SPLASH_TIME_OUT = 3000;
    private Typeface type;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        textView = (TextView)findViewById(R.id.textView);
        textSize = getTextSize();

        stringBuilder = getResources().getString(R.string.bubble_level);

        type = Typeface.createFromAsset(getAssets(), font);
        textView.setTypeface(type);
        textView.setText(stringBuilder);
        textView.setTextSize(textSize);

        new Handler().postDelayed(new Runnable() {

            @Override
            public void run() {
                Intent i = new Intent(SplashScreen.this, MainActivity.class);
                startActivity(i);
                finish();
            }
        }, SPLASH_TIME_OUT);
    }

    private int getTextSize() {
        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        int width = size.x;
        int height = size.y;
        return height/15;
    }
}
