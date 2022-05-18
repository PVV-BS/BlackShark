package org.bshark.blackshark;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.Override;
import java.util.Timer;
import java.util.TimerTask;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.hardware.input.InputManager;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.view.KeyEvent;
import android.view.WindowManager;
import android.os.Bundle;
import android.os.StrictMode;
import android.graphics.Canvas;
import android.view.*;
import android.view.inputmethod.InputMethodManager;


public class BlackSharkApplication extends Activity {

    private static final int OPCODE_SHOW_KEYBOARD   = 6;
    private static final int OPCODE_HIDE_KEYBOARD   = 7;
    private static final int OPCODE_EXIT            = 8;
    private static final int OPCODE_ANIMATION_RUN   = 9;
    private static final int OPCODE_ANIMATION_STOP  = 10;
    private static final int OPCODE_LIST_ACTIONS    = 11;

    private static final int SHIFT_STATE_SHIFT      = 1;
    private static final int SHIFT_STATE_CTRL       = 2;
    private static final int SHIFT_STATE_ALT        = 4;
    private static final int SHIFT_STATE_META       = 8; // ???
    private static final int SHIFT_STATE_CAPS       = 16;
    private static final int SHIFT_STATE_NUM        = 32;
    private static final int SHIFT_STATE_LONG       = 64;


    public native int bsNativeInit(String appPath, String filesPath);
    public native void bsNativeOnViewCreated(Object nativeHandle, float displayWidthPixels, float displayHeightPixels, float dpiX, float dpiY);
    public native void bsNativeOnViewChanged(int Width, int Height);
    public native int bsNativeOnDraw();
    public native void bsNativeOnChangeFocus(Object nativeHandle, boolean isFocused);
    private native int bsNativeOnTouch(int ActionId, int PointerID, float X, float Y, float Pressure);
    public native int bsNativeGetIntAttribute(String Name, int Default);
    public native boolean bsNativeGetBoolAttribute(String Name, boolean Default);


    public native void bsNativeOnViewDestroy();

    public native int bsNativeOnBackPressed();

    public native int bsNativeOnKeyDown(char keyChar, int keyCode, int shiftState);
    public native int bsNativeOnKeyUp(char keyChar, int keyCode, int shiftState);
    public native int bsNativeNextAction();

//
//    public native int bsNativeOnRotate(int rotate);
//
//    public native void bsNativeOnConfigurationChanged();

//    public native void bsNativeOnActivityResult(int requestCode, int resultCode);

//    public native void bsNativeOnFlingGestureDetected(int direction);
//
//    public native void bsNativeOnLostFocus(String text);
//
//    public native void bsNativeOnFocus(String text);
//
//    public native void bsNativeOnRequestPermissionResult(int requestCode, String permission, int grantResult);

//    public native void bsNativeOnRunOnUiThread(int tag);

    private int screenOrientation = 0; //For update screen orientation.
    private float dpiX = 96;
    private float dpiY = 96;
    private float screenWidth;
    private float screenHeight;
    private String appSourceDir;
    private String dataDir;
    private BlackSharkSurfaceView glSurfaceView;
    private boolean maxFps = false;
    private UpdateTask updateTask;
    private Timer timer;
    private boolean isPaused = false;

    // update task
    class UpdateTask extends TimerTask {

//        final Handler h = new Handler( new Handler.Callback() {
//
//            @Override
//            public boolean handleMessage(Message msg) {
//
//                //glSurfaceView.invalidate();
//                //bsNativeOnDraw();
//                //glSurfaceView.dispatchTouchEvent();
//
//                return true;
//            }
//        });

        @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
        @Override
        public void run() {
            if (isPaused)
                return;
            //glSurfaceView.postInvalidateOnAnimation();
            glSurfaceView.postInvalidate();
        }
    };


    public class BlackSharkSurfaceView extends SurfaceView implements SurfaceHolder.Callback {

    	public BlackSharkSurfaceView(Context context) {
            super(context);
            getHolder().addCallback(this);
            onRestart();
        }

        @Override
        protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        	super.onSizeChanged(w, h, oldw, oldh);

            //if( w < h ) screenOrientation = 1;
            //if( w > h ) screenOrientation = 2;

            //bsNativeOnRotate(screenOrientation);
            bsNativeOnViewChanged(w, h);
        }
        
        @Override
        protected void onDraw(Canvas canvas) {
            int opCode = bsNativeOnDraw();
            if (opCode > 0)
                processOpCode(opCode);
        }

        @Override
        public void surfaceCreated(SurfaceHolder holder) {
    	    // set native handle ANativeWindow is described here:
            // https://android.googlesource.com/platform/frameworks/native/+/master/libs/nativewindow/include/android/native_window.h
            bsNativeOnViewCreated(getHolder().getSurface(), screenWidth, screenHeight, dpiX, dpiY);
            maxFps = bsNativeGetBoolAttribute("MaxFps", false);
            if (maxFps)
                runLoop();
        }

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
            bsNativeOnViewChanged(width, height);
        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {

            //bsNativeOnViewDestroy();
            stopLoop();
        }

        @Override
        public boolean onTouchEvent(MotionEvent event ){

            int action = event.getAction();
            int actionType = action & MotionEvent.ACTION_MASK;
            int opCode = -1;
            switch ( actionType )
            {
                case MotionEvent.ACTION_DOWN: {
                    int count = event.getPointerCount();
                    for ( int i = 0; i < count; i++ )
                    {
                        int pointerID = event.getPointerId( i );
                        opCode = bsNativeOnTouch(MotionEvent.ACTION_DOWN, pointerID, event.getX( i ), event.getY( i ), event.getPressure( i ) );
                    }
                    break;
                }

                case MotionEvent.ACTION_MOVE: {
                    int count = event.getPointerCount();
                    for ( int i = 0; i < count; i++ )
                    {
                        int pointerID = event.getPointerId( i );
                        opCode = bsNativeOnTouch(MotionEvent.ACTION_MOVE, pointerID, event.getX( i ), event.getY( i ), event.getPressure( i ) );
                    }
                    break;
                }

                case MotionEvent.ACTION_UP:
                {
                    int count = event.getPointerCount();
                    for ( int i = 0; i < count; i++ )
                    {
                        int pointerID = event.getPointerId( i );
                        opCode = bsNativeOnTouch(MotionEvent.ACTION_UP, pointerID, event.getX( i ), event.getY( i ), 0 );
                    }
                    break;
                }

                case MotionEvent.ACTION_POINTER_DOWN:
                {
                    int pointerID = ( action & MotionEvent.ACTION_POINTER_ID_MASK ) >> MotionEvent.ACTION_POINTER_ID_SHIFT;
                    int pointerIndex = event.getPointerId( pointerID );
                    if ( pointerID >= 0 && pointerID < event.getPointerCount() )
                        opCode = bsNativeOnTouch(MotionEvent.ACTION_DOWN, pointerIndex, event.getX( pointerID ), event.getY( pointerID ), event.getPressure( pointerID ) );
                    break;
                }

                case MotionEvent.ACTION_POINTER_UP:
                {
                    int pointerID = ( action & MotionEvent.ACTION_POINTER_ID_MASK ) >> MotionEvent.ACTION_POINTER_ID_SHIFT;
                    int pointerIndex = event.getPointerId( pointerID );
                    if ( pointerID >= 0 && pointerID < event.getPointerCount() )
                        opCode = bsNativeOnTouch(MotionEvent.ACTION_UP, pointerIndex, event.getX( pointerID ), event.getY( pointerID ), 0 );
                    break;
                }
//                default:
//                {
//                    int count = event.getPointerCount();
//                    for ( int i = 0; i < count; i++ )
//                    {
//                        int pointerID = event.getPointerId( i );
//                        bsNativeOnTouch(MotionEvent.ACTION_UP, pointerID, event.getX( i ), event.getY( i ), 0 );
//                    }
//                    break;
//                }

            }

            processOpCode(opCode);

            if (!maxFps)
                bsNativeOnDraw();

            return true;
        }

    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        System.loadLibrary("blackshark");
        appSourceDir = getApplicationInfo().sourceDir;
        dataDir = getFilesDir().getAbsolutePath();

        //ref. http://stackoverflow.com/questions/8706464/defaulthttpclient-to-androidhttpclient
        int systemVersion = android.os.Build.VERSION.SDK_INT;

        if (systemVersion > 9) {
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);
        }

        File file = new File(dataDir + "/Shaders");
        if (!file.exists()) {
            try {
                unpackAssets();
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        screenWidth  = getResources().getDisplayMetrics().widthPixels;
        screenHeight = getResources().getDisplayMetrics().heightPixels;
        dpiX = getResources().getDisplayMetrics().xdpi;
        dpiY = getResources().getDisplayMetrics().ydpi;

        // you can set own orientation of screen for your application
        screenOrientation = bsNativeInit(appSourceDir, dataDir);

        // TODO: request full screen option???
        getWindow().setFlags( WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN );

        getActionBar().hide();

        //screenOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;//bsNativeGetIntAttribute("ScreenOrientation", ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        switch(screenOrientation) {
            case 0:
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                break;
            case 1:
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                break;
            default : ; // Device Default , Rotation by Device
        }

        glSurfaceView = new BlackSharkSurfaceView(this);

        setContentView(glSurfaceView);

        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
        //getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);

        glSurfaceView.requestLayout();
        glSurfaceView.setWillNotDraw(false);
        glSurfaceView.setFocusable(true);
        glSurfaceView.setFocusableInTouchMode(true);

    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        bsNativeOnChangeFocus(glSurfaceView.getHolder().getSurface(), hasFocus);
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        bsNativeOnViewDestroy();
        stopLoop();
    }
    
    @Override
    public void onBackPressed() {
        //bsNativeOnBackPressed();
    }
    
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
    	super.onConfigurationChanged(newConfig);    
    	
    	screenOrientation = newConfig.orientation;
        //newConfig.
    	
    	glSurfaceView.requestLayout();
    	//bsNativeOnChanged();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        int action = event.getAction();
        if (action == KeyEvent.ACTION_DOWN) {
            return doOnKeyDown(event.getKeyCode(), event);
        } else
        if (action == KeyEvent.ACTION_UP) {
            return doOnKeyUp(event.getKeyCode(), event);
        } else
        if (action == KeyEvent.ACTION_MULTIPLE) {
            boolean res = doOnKeyDown(event.getKeyCode(), event);
            if (doOnKeyUp(event.getKeyCode(), event))
                res = true;
            return res;
        }
        return false;
    }

    private boolean doOnKeyDown(int keyCode, KeyEvent event) {

        char c = getCharKeyEvent(event);

        int opCode = -1;
        int shiftState = getShiftState(event);

        switch(keyCode) {

            case KeyEvent.KEYCODE_BACK:
             //opCode = bsNativeOnBackPressed();

             opCode = bsNativeOnKeyDown(c, keyCode, shiftState);
             if (opCode == OPCODE_EXIT) { //continue ...
                 return false;         }
             else {  // exit!
                 return true;
             }

            /* case KeyEvent.KEYCODE_MENU:
             //opCode = bsNativeOnKeyDown(c,keyCode,KeyEvent.keyCodeToString(keyCode));
             break;

            case KeyEvent.KEYCODE_SEARCH:
              //opCode = bsNativeOnKeyDown(c,keyCode,KeyEvent.keyCodeToString(keyCode));
              break;

            case KeyEvent.KEYCODE_VOLUME_UP:
              //event.startTracking();  //TODO
              //opCode = bsNativeOnKeyDown(c,keyCode,KeyEvent.keyCodeToString(keyCode));
              break;

            case KeyEvent.KEYCODE_VOLUME_DOWN:
              //mute = bsNativeOnKeyDown(c,keyCode,KeyEvent.keyCodeToString(keyCode));
              break;*/

              /*commented! need SDK API >= 18 [Android 4.3] to compile!*/

            /*case KeyEvent.KEYCODE_BRIGHTNESS_DOWN:
                bsNativeOnKeyDown(c,keyCode,KeyEvent.keyCodeToString(keyCode));
                break;
            case KeyEvent.KEYCODE_BRIGHTNESS_UP:
                bsNativeOnKeyDown(c,keyCode,KeyEvent.keyCodeToString(keyCode));
                break;


            case KeyEvent.KEYCODE_HEADSETHOOK:
                //opCode = bsNativeOnKeyDown(c, keyCode, KeyEvent.keyCodeToString(keyCode));
                break;

            case KeyEvent.KEYCODE_DEL:
                opCode = bsNativeOnKeyDown(c, keyCode, KeyEvent.keyCodeToString(keyCode));
                break;

            case KeyEvent.KEYCODE_NUM:
                //bsNativeOnKeyDown(c, keyCode, KeyEvent.keyCodeToString(keyCode));
                break;

            case KeyEvent.KEYCODE_NUM_LOCK:
                //bsNativeOnKeyDown(c, keyCode, KeyEvent.keyCodeToString(keyCode));
                break;*/

            default: {
                opCode = bsNativeOnKeyDown(c, keyCode, shiftState);
            }
        }

        if (opCode >= 0)
        {
            processOpCode(opCode);
            return true;
        } else {
             return super.onKeyDown(keyCode, event);
        }
    }

    private boolean doOnKeyUp(int keyCode, KeyEvent event) {

        char c = getCharKeyEvent(event);

        int shiftState = getShiftState(event);

        bsNativeOnKeyUp(c, keyCode, shiftState);
        return true;
    }

    private char getCharKeyEvent(KeyEvent event) {
        char result = 0;
        String characters = event.getCharacters();
        if ((characters != null) && (characters.length() > 0))
        {
            result = characters.charAt(0);
        } else {
            int uc = event.getUnicodeChar(event.getMetaState());
            //c = event.getDisplayLabel();
            result = (char)uc;
            if (!event.isShiftPressed())
                result = String.valueOf(result).toLowerCase().charAt(0);
        }
        return result;
    }

    private void runLoop(){
        if (updateTask != null)
            return;
        timer = new Timer();
        updateTask = new UpdateTask();
        timer.schedule(updateTask, 0,1);
    }

    private void stopLoop() {
        if (updateTask != null) {
            updateTask.cancel();
//            try {
//                updateTask.wait();
//            } catch (InterruptedException e) {
//                e.printStackTrace();
//            }
            updateTask = null;
            timer = null;
        }
    }

    private void unpackAssets() throws IOException {
        ZipInputStream zis = null;
        try {
            zis = new ZipInputStream(new FileInputStream(appSourceDir));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        ZipEntry zipEntry = null;
        try {
            zipEntry = zis.getNextEntry();
        } catch (IOException e) {
            e.printStackTrace();
        }
        byte[] buffer = new byte[1024];
        while (zipEntry != null) {
            if (!zipEntry.isDirectory() && (zipEntry.toString().contains("assets/"))) {
                String newFile = dataDir + "/" + zipEntry.toString().substring(7);
                // write file content
//                try {
//                    Files.createFile(Paths.get(newFile));
//                } catch (IOException e) {
//                    e.printStackTrace();
//                }
                int len;
                File file = new File(newFile);
                File parent = new File(file.getParent());
                if (!parent.exists()) {
                    parent.mkdirs();
                }
                //File f = Files.exists()
                //if (path.)
                FileOutputStream fos = new FileOutputStream(newFile);
                while (true) {
                    len = 0;
                    try {
                        len = zis.read(buffer);
                        if (len <= 0) break;
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    try {
                        fos.write(buffer, 0, len);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                try {
                    fos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                fos = null;
                //zipEntry.
            }
            try {
                zipEntry = zis.getNextEntry();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        zis = null;
   }

    private void showKeyboard() {
       InputMethodManager imm = (InputMethodManager) getSystemService(Activity.INPUT_METHOD_SERVICE);
       imm.toggleSoftInput( InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_NOT_ALWAYS );
    }

    private void hideKeyboard() {
       InputMethodManager imm = (InputMethodManager) getSystemService(Activity.INPUT_METHOD_SERVICE);
       imm.hideSoftInputFromWindow( glSurfaceView.getWindowToken(), 0 );
    }

    private int getShiftState(KeyEvent event) {
        int result = 0;

        if (event.isShiftPressed())
            result |= SHIFT_STATE_SHIFT;

        if (event.isAltPressed())
            result |= SHIFT_STATE_ALT;

        if (event.isCtrlPressed())
            result |= SHIFT_STATE_CTRL;

        if (event.isMetaPressed())
            result |= SHIFT_STATE_META;

        if (event.isLongPress())
            result |= SHIFT_STATE_LONG;

        if (event.isCapsLockOn())
            result |= SHIFT_STATE_CAPS;

        if (event.isNumLockOn())
            result |= SHIFT_STATE_NUM;

        return result;
    }

    private void processOpCode(int OpCode) {
        if (OpCode == OPCODE_LIST_ACTIONS) {
            int opCode = bsNativeNextAction();
            while (opCode > 0)
            {
                processOpCodeDo(opCode);
                opCode = bsNativeNextAction();
            }
        } else if (OpCode == OPCODE_ANIMATION_STOP) { // most often opcode process here
            if ((!maxFps) && (updateTask != null))
                stopLoop();
        } else
            processOpCodeDo(OpCode);
    }

    private void processOpCodeDo(int OpCode) {

        switch (OpCode)
        {
            case OPCODE_SHOW_KEYBOARD:{
                showKeyboard();
                break;
            }

            case OPCODE_HIDE_KEYBOARD:{
                hideKeyboard();
                break;
            }

            case OPCODE_ANIMATION_RUN:{
                if ((!maxFps) && (updateTask == null))
                    runLoop();
                break;
            }

        }

    }

}
