package com.example.demon.accelerometer;

import android.content.Context;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;

/**
 * Created by Demon on 09.06.2015.
 */

public class Accelerometer extends View {

    int widthSize, heightSize, widthMode, heightMode;
    int widthResult, heightResult;
    int centerX, centerY, radius, x1, x2, y1, y2, x3, y3, x3_correct;
    Path path, path1;
    Paint paint;
    Rect rect;
    float x, y, x_degrees, y_degrees;

    public Accelerometer(Context context, AttributeSet attrs) {
        super(context, attrs);
        initDrawTools();
    }

    private void initDrawTools() {
        paint = new Paint();
        paint.setAntiAlias(true);
        paint.setStrokeWidth(4);
        paint.setStyle(Paint.Style.STROKE);
        paint.setColor(Color.BLACK);

        path = new Path();
        path1 = new Path();
    }

    public void setXY(float x, float y){
        this.x = x;
        this.y = y;
    }

    public float getXdimen(){
        return x;
    }

    public float getYdimen(){
        return y;
    }


    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);

        widthMode = MeasureSpec.getMode(widthMeasureSpec);
        widthSize = MeasureSpec.getSize(widthMeasureSpec);

        heightMode = MeasureSpec.getMode(heightMeasureSpec);
        heightSize = MeasureSpec.getSize(heightMeasureSpec);

        widthResult = chooseResult(widthMode, widthSize);
        heightResult = chooseResult(heightMode, heightSize);

        centerX = widthResult/2;
        centerY = heightResult/2;

        setMeasuredDimension(widthResult, heightResult);
    }

    private int chooseResult(int mode, int size) {
        if(mode == MeasureSpec.AT_MOST || mode == MeasureSpec.EXACTLY) {
            return size;} else {
            return 300;}
        }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        drawBackground(canvas);
        drawBulbe(canvas);
    }

    private void drawBulbe(Canvas canvas) {
        createSmallRect();
        offsetRect();
        canvas.drawBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.booble_gradient), null, rect, paint);
    }

    private void offsetRect() {
        if((Math.pow(x3, 2) + Math.pow(y3, 2))<=Math.pow(radius*4, 2)) {
            rect.offset(x3, -y3);
        } else {
            correctOffsetRect();
        }
    }

    private void correctOffsetRect() {
        x3_correct = (int) Math.sqrt(Math.pow(radius*4, 2)-Math.pow(y3, 2));
        if(x3>=0 || y3>=0){
            rect.offset(x3_correct, -y3);
        } else if(x3<0 || y3>=0){
            rect.offset(-x3_correct, -y3);
        } else if(x3<0 || y3<0){
            rect.offset(-x3_correct, y3);
        } else if(x3>=0 || y3<0){
            rect.offset(x3_correct, y3);
        } else if(x3<0 || y3>=0){
            rect.offset(-x3_correct, y3);
        }
    }

    private void createSmallRect() {
        x1 = (int) (centerX - radius*0.8);
        y1 = (int) (centerY - radius*0.8);
        x2 = (int) (centerX + radius*0.8);
        y2 = (int) (centerY + radius*0.8);
        rect = new Rect(x1, y1, x2, y2);
        x3= (int) (x*40);
        y3 = (int) (y*40);
    }

    private void drawBackground(Canvas canvas) {
        createBigRect(canvas);
        designBigRect(canvas);
    }

    private void designBigRect(Canvas canvas) {
        path.moveTo(centerX, centerY-radius*4);
        path.lineTo(centerX, centerY+radius*4);

        path.moveTo(centerX-radius*4, centerY);
        path.lineTo(centerX+radius*4, centerY);

        path.addCircle(centerX, centerY, radius, Path.Direction.CW);
        path.addCircle(centerX, centerY, radius*2, Path.Direction.CW);
        path.addCircle(centerX, centerY, radius*3, Path.Direction.CW);
        path.addCircle(centerX, centerY, radius*4, Path.Direction.CW);
        canvas.drawPath(path, paint);
    }

    private void createBigRect(Canvas canvas) {
        radius = Math.min(widthResult, heightResult)/10;
        int x1 = centerX - radius*4, y1 = centerY - radius*4, x2 = centerX + radius*4,  y2 = centerY + radius*4;
        Rect rect = new Rect(x1, y1, x2, y2);
        canvas.drawBitmap(BitmapFactory.decodeResource(getResources(), R.drawable.circle_background), null, rect, paint);

    }

    // обновляем скорость при каждом вызове
    public void onXY_Update(float x, float y) {
        this.setXY(x, y);
        this.invalidate();
    }

}
