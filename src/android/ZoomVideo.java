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

    private String jwtToken;
    private String sessionName;
    private String userName;
    private String domain;
    private String waitingMessage;

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
            this.jwtToken = args.getString(0);
            this.sessionName = args.getString(1);
            this.userName = args.getString(2);
            this.domain = args.getString(3);
            this.waitingMessage = args.getString(5);

            final String jwtToken = this.jwtToken;
            final String sessionName = this.sessionName;
            final String userName = this.userName;
            final String domain = this.domain;
            final String waitingMessage = this.waitingMessage;

            final CordovaPlugin that = this;
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    Intent intentZoomVideo = new Intent(that.cordova.getActivity().getBaseContext(), SessionActivity.class);
                    intentZoomVideo.putExtra("jwtToken", jwtToken);
                    intentZoomVideo.putExtra("sessionName", sessionName);
                    intentZoomVideo.putExtra("userName", userName);
                    intentZoomVideo.putExtra("domain", domain);
                    intentZoomVideo.putExtra("waitingMessage", waitingMessage);

                    that.cordova.startActivityForResult(that, intentZoomVideo, 0);
                }
            });
        } catch (JSONException e) {
            LOG.e("ROOM", "Invalid JSON string: ", e);
        }
    }

    public Bundle onSaveInstanceState() {
        Bundle state = new Bundle();
        state.putString("jwtToken", this.jwtToken);
        state.putString("sessionName", this.sessionName);
        state.putString("userName", this.userName);
        state.putString("domain", this.domain);
        state.putString("waitingMessage", this.waitingMessage);
        return state;
    }

    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.jwtToken = state.getString("jwtToken");
        this.sessionName = state.getString("sessionName");
        this.userName = state.getString("userName");
        this.domain = state.getString("domain");
        this.waitingMessage = state.getString("waitingMessage");
        this.callbackContext = callbackContext;
    }
}
