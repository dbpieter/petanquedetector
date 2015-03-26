package com.example.phonerotation;

import android.app.Activity;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;


public class MainActivity extends Activity implements SensorEventListener {
	
	private SensorManager mSensorManager;
	private Sensor mSensor;
	private TextView views, rotateUp, rotateDown, rotateLeft, rotateRight;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        mSensorManager.registerListener(this, mSensor, SensorManager.SENSOR_DELAY_NORMAL);
    	views = (TextView) findViewById(R.id.acceleration);
    	rotateUp = (TextView) findViewById(R.id.up);
    	rotateDown = (TextView) findViewById(R.id.down);
    	rotateLeft = (TextView) findViewById(R.id.left);
    	rotateRight = (TextView) findViewById(R.id.right);

    }

	@Override
	public void onSensorChanged(SensorEvent event) {
		// TODO Auto-generated method stub
		views.setText("X: " + event.values[0] + "\nY: " + event.values[1] + "\nZ: " + event.values[2]);
		boolean balance = tiltDevice(event);
		// if balance you can press the button, take picture.
		if(balance){
			views.setText("GSM ligt perfect plat!");
		}
		
	}
	
	protected boolean tiltDevice(SensorEvent event){
		boolean xBalance = false;
		boolean yBalance = false;
		
		//Check if the phone is straight on the x-axis
		if(event.values[0] >= 1){
			rotateUp.setVisibility(View.VISIBLE);
			rotateDown.setVisibility(View.INVISIBLE);
		}
		else if(event.values[0] <= -1){
			rotateUp.setVisibility(View.INVISIBLE);
			rotateDown.setVisibility(View.VISIBLE);		
		}
		else{
			xBalance = true;
			rotateUp.setVisibility(View.INVISIBLE);
			rotateDown.setVisibility(View.INVISIBLE);		
		}
		
		//Check if the phone is straight on the y-axis
		if(event.values[1] >= 1){
			rotateLeft.setVisibility(View.VISIBLE);
			rotateRight.setVisibility(View.INVISIBLE);		
		}
		else if(event.values[1] <= -1){
			rotateLeft.setVisibility(View.INVISIBLE);
			rotateRight.setVisibility(View.VISIBLE);	
		}
		else{
			yBalance = true;
			rotateLeft.setVisibility(View.INVISIBLE);
			rotateRight.setVisibility(View.INVISIBLE);	
		}
		
		if(xBalance && yBalance){
			return true;
		}
		return false;	
	}

	@Override
	public void onAccuracyChanged(Sensor sensor, int accuracy) {
		// TODO Auto-generated method stub
		
	}
}
