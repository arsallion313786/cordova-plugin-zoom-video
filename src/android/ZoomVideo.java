package cordova.plugin.zoomvideo;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.LOG;

import org.json.JSONArray;
import org.json.JSONException;

import android.os.Bundle;
import android.content.Intent;

public class ZoomVideo extends CordovaPlugin {
    private CallbackContext callbackContext;
    private CordovaInterface cordova;

    private String sdkKey;
    private String sdkSecret;
    private String sessionName;
    private int roleType;
    private String sessionKey;
    private String userIdentity;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        this.cordova = cordova;
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        if (action.equals("openSession")) {
            this.openSession(args);
        }
        return true;
    }

    private void openSession(final JSONArray args) {

        try {
            this.sdkKey = args.getString(0);
            this.sdkSecret = args.getString(1);
            this.sessionName = args.getString(2);
            this.sessionKey = args.getString(3);
            this.userIdentity = args.getString(4);
            this.roleType = 1;

            final String sdkKey = this.sdkKey;
            final String sdkSecret = this.sdkSecret;
            final String sessionName = this.sessionName;
            final String sessionKey = this.sessionKey;
            final String userIdentity = this.userIdentity;
            final int roleType = this.roleType;

            LOG.d("SDK KEY", sdkKey);
            LOG.d("SDK SECRET", sdkSecret);
            LOG.d("SESSION NAME", sessionName);
            LOG.d("SESSION KEY", sessionKey);
            LOG.d("SESSION IDENTITY", userIdentity);
            LOG.d("ROLE TYPE", String.valueOf(roleType));

            final CordovaPlugin that = this;
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    Intent intentZoomVideo = new Intent(that.cordova.getActivity().getBaseContext(), SessionActivity.class);
                    intentZoomVideo.putExtra("sdkKey", sdkKey);
                    intentZoomVideo.putExtra("sdkSecret", sdkSecret);
                    intentZoomVideo.putExtra("sessionName", sessionName);
                    intentZoomVideo.putExtra("sessionKey", sessionKey);
                    intentZoomVideo.putExtra("userIdentity", userIdentity);
                    intentZoomVideo.putExtra("roleType", roleType);

                    that.cordova.startActivityForResult(that, intentZoomVideo, 0);
                }
            });
        } catch (JSONException e) {
            LOG.e("ROOM", "Invalid JSON string: ", e);
        }
    }

    public Bundle onSaveInstanceState() {
        Bundle state = new Bundle();
        state.putString("sdkKey", this.sdkKey);
        state.putString("sdkSecret", this.sdkSecret);
        state.putString("sessionName", this.sessionName);
        state.putString("roleType", String.valueOf(this.roleType));
        state.putString("sessionKey", this.sessionKey);
        state.putString("userIdentity", this.userIdentity);
        return state;
    }

    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.sdkKey = state.getString("sdkKey");
        this.sdkSecret = state.getString("sdkSecret");
        this.sessionName = state.getString("sessionName");
        this.roleType = Integer.parseInt(state.getString("roleType"));
        this.sessionKey = state.getString("sessionKey");
        this.userIdentity = state.getString("userIdentity");
        this.callbackContext = callbackContext;
    }
}
