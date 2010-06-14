package es.softwareprocess.HelloAndroid;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class HelloAndroid extends Activity {
	BallsView bv = null;
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);        
        bv = new BallsView(this);       
        setContentView(bv);
    }

    
}