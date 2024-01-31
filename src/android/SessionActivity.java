package cordova.plugin.zoomvideo;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.media.AudioManager;
import android.os.Bundle;

//import android.support.annotation.NonNull;
//import android.support.design.widget.FloatingActionButton;
//import android.support.design.widget.Snackbar;
//import android.support.v4.app.ActivityCompat;
//import android.support.v4.content.ContextCompat;
//import android.support.v7.app.AppCompatActivity;

import androidx.annotation.NonNull;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.appcompat.app.AppCompatActivity;

import androidx.appcompat.app.AlertDialog;

import android.util.Base64;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;
import android.widget.Toast;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.List;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import us.zoom.sdk.ZoomVideoSDK;
import us.zoom.sdk.ZoomVideoSDKAnnotationHelper;
import us.zoom.sdk.ZoomVideoSDKAudioHelper;
import us.zoom.sdk.ZoomVideoSDKAudioOption;
import us.zoom.sdk.ZoomVideoSDKAudioRawData;
import us.zoom.sdk.ZoomVideoSDKAudioStatus;
import us.zoom.sdk.ZoomVideoSDKCRCCallStatus;
import us.zoom.sdk.ZoomVideoSDKChatHelper;
import us.zoom.sdk.ZoomVideoSDKChatMessage;
import us.zoom.sdk.ZoomVideoSDKChatMessageDeleteType;
import us.zoom.sdk.ZoomVideoSDKChatPrivilegeType;
import us.zoom.sdk.ZoomVideoSDKErrors;
import us.zoom.sdk.ZoomVideoSDKInitParams;
import us.zoom.sdk.ZoomVideoSDKLiveStreamHelper;
import us.zoom.sdk.ZoomVideoSDKLiveStreamStatus;
import us.zoom.sdk.ZoomVideoSDKLiveTranscriptionHelper;
import us.zoom.sdk.ZoomVideoSDKMultiCameraStreamStatus;
import us.zoom.sdk.ZoomVideoSDKNetworkStatus;
import us.zoom.sdk.ZoomVideoSDKPasswordHandler;
import us.zoom.sdk.ZoomVideoSDKPhoneFailedReason;
import us.zoom.sdk.ZoomVideoSDKPhoneStatus;
import us.zoom.sdk.ZoomVideoSDKProxySettingHandler;
import us.zoom.sdk.ZoomVideoSDKRawDataPipe;
import us.zoom.sdk.ZoomVideoSDKRecordingConsentHandler;
import us.zoom.sdk.ZoomVideoSDKRecordingStatus;
import us.zoom.sdk.ZoomVideoSDKSSLCertificateInfo;
import us.zoom.sdk.ZoomVideoSDKSessionContext;
import us.zoom.sdk.ZoomVideoSDKShareHelper;
import us.zoom.sdk.ZoomVideoSDKShareStatus;
import us.zoom.sdk.ZoomVideoSDKTestMicStatus;
import us.zoom.sdk.ZoomVideoSDKUser;
import us.zoom.sdk.ZoomVideoSDKUserHelper;
import us.zoom.sdk.ZoomVideoSDKVideoCanvas;
import us.zoom.sdk.ZoomVideoSDKVideoOption;
import us.zoom.sdk.ZoomVideoSDKVideoResolution;
import us.zoom.sdk.ZoomVideoSDKVideoSubscribeFailReason;
import us.zoom.sdk.ZoomVideoSDKVideoView;
import us.zoom.sdk.ZoomVideoSDKVideoHelper;
import us.zoom.sdk.ZoomVideoSDKDelegate;
import us.zoom.sdk.ZoomVideoSDKVideoAspect;

public class SessionActivity extends AppCompatActivity implements ZoomVideoSDKDelegate  {
    private static final int CAMERA_MIC_PERMISSION_REQUEST_CODE = 1;

    /*
     * Necessary parameters to create or join the Zoom Video session.
     */
    private String jwtToken;
    private String sessionName;
    private String userName;
    private String domain;

    /*
     * Video views.
     */
    private ZoomVideoSDKVideoView primaryVideoView;
    private ZoomVideoSDKVideoView thumbnailVideoView;
    private ZoomVideoSDKVideoView secondaryThumbnailVideoView;
    private ZoomVideoSDKUser primaryUser;
    private ZoomVideoSDKUser thumbnailUser;
    private ZoomVideoSDKUser secondaryThumbnailUser;

    /*
     * Android application UI elements
     */
    private TextView waitingMessageTextView;
    private TextView videoStatusTextView;
    private TextView identityTextView;
    private FloatingActionButton connectActionFab;
    private FloatingActionButton disconnectActionFab;
    private FloatingActionButton switchCameraActionFab;
    private FloatingActionButton localVideoActionFab;
    private FloatingActionButton muteActionFab;
    private FloatingActionButton speakerActionFab;
    private AlertDialog alertDialog;
    private AudioManager audioManager;

    private Context context;
    final String LAYOUT = "layout";
    final String STRING = "string";
    final String DRAWABLE = "drawable";
    final String ID = "id";

    public static int getResourceId(Context context, String group, String key) {
        return context.getResources().getIdentifier(key, group, context.getPackageName());
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        context = this;

        setContentView(getResourceId(context,LAYOUT,"activity_video"));

        primaryVideoView = findViewById(getResourceId(context,ID,("primary_video_view")));
        thumbnailVideoView = findViewById(getResourceId(context,ID,("thumbnail_video_view")));
        secondaryThumbnailVideoView = findViewById(getResourceId(context,ID,("secondary_thumbnail_video_view")));

        waitingMessageTextView = findViewById(getResourceId(context,ID,("waiting_message_textview")));
        videoStatusTextView = findViewById(getResourceId(context,ID,("video_status_textview")));
        identityTextView = findViewById(getResourceId(context,ID,("identity_textview")));

        connectActionFab = findViewById(getResourceId(context,ID,("connect_action_fab")));
        disconnectActionFab = findViewById(getResourceId(context,ID,("disconnect_action_fab")));
        switchCameraActionFab = findViewById(getResourceId(context,ID,("switch_camera_action_fab")));
        localVideoActionFab = findViewById(getResourceId(context,ID,("local_video_action_fab")));
        muteActionFab = findViewById(getResourceId(context,ID,("mute_action_fab")));
        speakerActionFab = findViewById(getResourceId(context,ID,("speaker_action_fab")));

        this.primaryUser = null;
        this.thumbnailUser = null;
        this.secondaryThumbnailUser = null;



        /*
         * Enable changing the volume using the up/down keys during a conversation
         */
        setVolumeControlStream(AudioManager.STREAM_VOICE_CALL);

        /*
         * Needed for setting/abandoning audio focus during call
         */
        audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);

        Intent intent = getIntent();
        this.jwtToken = intent.getStringExtra("jwtToken");
        this.sessionName = intent.getStringExtra("sessionName");
        this.userName = intent.getStringExtra("userName");
        this.domain = intent.getStringExtra("domain");
        waitingMessageTextView.setText(intent.getStringExtra("waitingMessage"));

        /*
         * Check camera and microphone permissions. Needed in Android M.
         */
        if (!checkPermissionForCameraAndMicrophone()) {
            requestPermissionForCameraAndMicrophone();
        } else {
            initializeSDK();
            joinSession();
            initializeUI();
        }
    }

    @Override
    protected void onResume() {
        /*
         * If the video was stopped when the app was put in the background, start again.
         */
        super.onResume();
        ZoomVideoSDK sdk = ZoomVideoSDK.getInstance();
        if(sdk.isInSession()) {
            Display display = ((WindowManager) getSystemService(WINDOW_SERVICE)).getDefaultDisplay();

            sdk.getVideoHelper().startVideo();
            sdk.getVideoHelper().rotateMyVideo(display.getRotation());
        }
    }

    @Override
    protected void onPause() {
        /*
         * Stop video before going in the background. This ensures that the
         * camera can be used by other applications while this app is in the background.
         */
        if(ZoomVideoSDK.getInstance().isInSession()) {
            ZoomVideoSDK.getInstance().getVideoHelper().stopVideo();
        }
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        /*
         * Always leave the session before leaving the Activity.
         */
        if (this.secondaryThumbnailUser != null) {
            this.secondaryThumbnailUser.getVideoCanvas().unSubscribe(this.secondaryThumbnailVideoView);
        }
        if (this.thumbnailUser != null) {
            this.thumbnailUser.getVideoCanvas().unSubscribe(this.thumbnailVideoView);
        }
        if (this.primaryUser != null) {
            this.primaryUser.getVideoCanvas().unSubscribe(this.primaryVideoView);
        }

        ZoomVideoSDK sdk = ZoomVideoSDK.getInstance();
        ZoomVideoSDKVideoHelper videoHelper = sdk.getVideoHelper();
        ZoomVideoSDKAudioHelper audioHelper = sdk.getAudioHelper();
        videoHelper.stopVideo();
        audioHelper.stopAudio();

        sdk.leaveSession(false);
        sdk.cleanup();
        super.onDestroy();
    }

    @Override
    public void onConfigurationChanged (@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        // We want to rotate the local video based on the phone rotation.
        ZoomVideoSDK sdk = ZoomVideoSDK.getInstance();
        if(sdk.isInSession()) {
            Display display = ((WindowManager) getSystemService(WINDOW_SERVICE)).getDefaultDisplay();
            sdk.getVideoHelper().rotateMyVideo(display.getRotation());
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == CAMERA_MIC_PERMISSION_REQUEST_CODE) {
            boolean cameraAndMicPermissionGranted = true;

            for (int grantResult : grantResults) {
                cameraAndMicPermissionGranted &= grantResult == PackageManager.PERMISSION_GRANTED;
            }

            if (cameraAndMicPermissionGranted) {
                initializeSDK();
                joinSession();
                initializeUI();
            } else {
                Toast.makeText(this, getResourceId(context,STRING,("permissions_needed")), Toast.LENGTH_LONG).show();
            }
        }
    }

    private boolean checkPermissionForCameraAndMicrophone(){
        int resultCamera = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
        int resultMic = ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO);
        return resultCamera == PackageManager.PERMISSION_GRANTED &&
                resultMic == PackageManager.PERMISSION_GRANTED;
    }

    private void requestPermissionForCameraAndMicrophone(){
        if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.CAMERA) ||
                ActivityCompat.shouldShowRequestPermissionRationale(this,
                        Manifest.permission.RECORD_AUDIO)) {
            Toast.makeText(this,
                    getResourceId(context,STRING,("permissions_needed")),
                    Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(
                    this,
                    new String[]{Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO},
                    CAMERA_MIC_PERMISSION_REQUEST_CODE);
        }
    }

//    private String getJWT(){
//        long iat = (System.currentTimeMillis()/1000) - 30;
//        long exp = iat + 60 * 60 * 2;
//
//        String header = "{\"alg\": \"HS256\", \"typ\": \"JWT\"}";
//        String payload = "{\"app_key\": \"" + this.sdkKey + "\"" +
//                ", \"tpc\": \"" + this.sessionName + "\"" +
//                ", \"role_type\": " + this.roleType +
//                ", \"session_key\": \"" + this.sessionKey + "\"" +
//                ", \"user_identity\": \"" + this.userIdentity + "\"" +
//                ", \"version\": 1" +
//                ", \"iat\": " + String.valueOf(iat) +
//                ", \"exp\": " + String.valueOf(exp) + "}";
//
//        try {
//            String headerBase64Str = Base64.encodeToString(header.getBytes(StandardCharsets.UTF_8),
//                    Base64.NO_WRAP| Base64.NO_PADDING | Base64.URL_SAFE);
//            String payloadBase64Str = Base64.encodeToString(payload.getBytes(StandardCharsets.UTF_8),
//                    Base64.NO_WRAP| Base64.NO_PADDING | Base64.URL_SAFE);
//
//            final Mac mac = Mac.getInstance("HmacSHA256");
//            SecretKeySpec secretKeySpec = new SecretKeySpec(this.sdkSecret.getBytes(), "HmacSHA256");
//            mac.init(secretKeySpec);
//
//            byte[] digest = mac.doFinal((headerBase64Str + "." + payloadBase64Str).getBytes());
//
//            return headerBase64Str + "." + payloadBase64Str + "." + Base64.encodeToString(digest,
//                    Base64.NO_WRAP| Base64.NO_PADDING | Base64.URL_SAFE);
//
//        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
//            e.printStackTrace();
//        }
//        return null;
//    }

    private void initializeSDK() {
        ZoomVideoSDKInitParams params = new ZoomVideoSDKInitParams();

        if (this.domain == null || this.domain.equals("")) {
            params.domain = "https://zoom.us";
        } else {
            params.domain = domain;
        }

        ZoomVideoSDK sdk = ZoomVideoSDK.getInstance();

        int initResult = sdk.initialize(this, params);
        if (initResult == ZoomVideoSDKErrors.Errors_Success) {
            /* The ZoomVideoSDKDelegate allows you to subscribe to callback events that provide
            status updates on the operations performed in your app that are related to
            the Video SDK. For example, you might want to be notified when a user has successfully
            joined or left a session.  */
            sdk.addListener(this);
        } else {
            // Something went wrong, see error code documentation
            Log.e("SessionActivity", "Initialize SDK error: " + initResult	);
        }
    }

    private void joinSession() {
        // Setup audio options
        ZoomVideoSDKAudioOption audioOptions = new ZoomVideoSDKAudioOption();
        audioOptions.connect = true; // Auto connect to audio upon joining
        audioOptions.mute = false; // Auto mute audio upon joining

        // Setup video options
        ZoomVideoSDKVideoOption videoOptions = new ZoomVideoSDKVideoOption();
        videoOptions.localVideoOn = true; // Turn on local/self video upon joining

        ZoomVideoSDKSessionContext sessionContext = new ZoomVideoSDKSessionContext();
        sessionContext.sessionName = this.sessionName;
        sessionContext.userName = this.userName;
        sessionContext.token = this.jwtToken;
        sessionContext.audioOption = audioOptions;
        sessionContext.videoOption = videoOptions;

        ZoomVideoSDK.getInstance().joinSession(sessionContext);
    }

    private void initializeUI() {
        connectActionFab.hide();

        disconnectActionFab.show();
        disconnectActionFab.setOnClickListener(disconnectClickListener());

        switchCameraActionFab.show();
        switchCameraActionFab.setOnClickListener(switchCameraClickListener());

        localVideoActionFab.show();
        localVideoActionFab.setOnClickListener(localVideoClickListener());

        muteActionFab.show();
        muteActionFab.setOnClickListener(muteClickListener());

        speakerActionFab.show();
        speakerActionFab.setOnClickListener(speakerClickListener());
    }

    private View.OnClickListener disconnectClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                /*
                 * The session will be left OnDestroy.
                 */
                finish();
            }
        };
    }

    private View.OnClickListener switchCameraClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ZoomVideoSDKVideoHelper videoHelper = ZoomVideoSDK.getInstance().getVideoHelper();
                videoHelper.switchCamera();
                videoHelper.mirrorMyVideo(false);
            }
        };
    }

    private View.OnClickListener localVideoClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                /*
                 * Enable/disable the local video
                 */
                int icon;
                ZoomVideoSDKUser myUser = ZoomVideoSDK.getInstance().getSession().getMySelf();
                ZoomVideoSDKVideoHelper videoHelper = ZoomVideoSDK.getInstance().getVideoHelper();

                if (myUser.getVideoCanvas().getVideoStatus().isOn()) {

                    videoHelper.stopVideo();

                    icon = getResourceId(context,DRAWABLE,("ic_videocam_off_red_24px"));
                    switchCameraActionFab.hide();
                } else {

                    videoHelper.startVideo();

                    icon = getResourceId(context,DRAWABLE,("ic_videocam_green_24px"));
                    switchCameraActionFab.show();
                }
                localVideoActionFab.setImageDrawable(ContextCompat.getDrawable(SessionActivity.this, icon));
            }
        };
    }

    private View.OnClickListener muteClickListener() {
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                /*
                 * Mute/unmute the local audio.
                 */
                ZoomVideoSDK sdk = ZoomVideoSDK.getInstance();
                ZoomVideoSDKUser myUser = sdk.getSession().getMySelf();
                ZoomVideoSDKAudioHelper audioHelper = sdk.getAudioHelper();

                int icon;
                if(myUser.getAudioStatus().isMuted()) {
                    audioHelper.unMuteAudio(myUser);
                    icon = getResourceId(context,DRAWABLE,("ic_mic_green_24px"));;
                } else {
                    audioHelper.muteAudio(myUser);
                    icon = getResourceId(context,DRAWABLE,("ic_mic_off_red_24px"));
                }
                muteActionFab.setImageDrawable(ContextCompat.getDrawable(SessionActivity.this, icon));
            }
        };
    }

    private View.OnClickListener speakerClickListener(){
        return new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (audioManager.isSpeakerphoneOn()) {
                    audioManager.setSpeakerphoneOn(false);
                    speakerActionFab.setImageDrawable(ContextCompat.getDrawable(getApplicationContext(),
                            getResourceId(context,DRAWABLE,("ic_volume_down_white_24px"))));
                } else {
                    audioManager.setSpeakerphoneOn(true);
                    speakerActionFab.setImageDrawable(ContextCompat.getDrawable(getApplicationContext(),
                            getResourceId(context,DRAWABLE,("ic_volume_down_green_24px"))));
                }
            }
        };
    }

    /* SDK callback listeners */
    @Override
    public void onSessionJoin() {
        ZoomVideoSDK sdk = ZoomVideoSDK.getInstance();
        ZoomVideoSDKUser myUser = sdk.getSession().getMySelf();
        ZoomVideoSDKVideoCanvas myCanvas = myUser.getVideoCanvas();

        /* Start Video */
        ZoomVideoSDKVideoHelper videoHelper = sdk.getVideoHelper();
        if (!myCanvas.getVideoStatus().isOn()) {
            videoHelper.startVideo();
        } else {
            Log.i("SessionActivity", "Video was already started onSessionJoin");
        }

        this.thumbnailVideoView.setVisibility(View.VISIBLE);
        this.thumbnailUser = myUser;
        myCanvas.subscribe(this.thumbnailVideoView,
                ZoomVideoSDKVideoAspect.ZoomVideoSDKVideoAspect_PanAndScan,
                ZoomVideoSDKVideoResolution.ZoomVideoSDKResolution_Auto);

        /* Start Audio */
        ZoomVideoSDKAudioStatus audioStatus = myUser.getAudioStatus();
        ZoomVideoSDKAudioStatus.ZoomVideoSDKAudioType audioType = audioStatus.getAudioType();
        ZoomVideoSDKAudioHelper audioHelper = sdk.getAudioHelper();
        if (audioType == ZoomVideoSDKAudioStatus.ZoomVideoSDKAudioType.ZoomVideoSDKAudioType_None) {
            audioHelper.startAudio();
        } else {
            Log.i("SessionActivity", "Audio was already started onSessionJoin");
        }
    }

    @Override
    public void onSessionLeave() {

    }

    @Override
    public void onError(int errorCode) {

    }

    @Override
    public void onUserJoin(ZoomVideoSDKUserHelper userHelper, List<ZoomVideoSDKUser> userList) {
        for (ZoomVideoSDKUser user : userList) {

            ZoomVideoSDKVideoCanvas userCanvas = user.getVideoCanvas();

            // Place the user in the primary view if it is available.
            if(this.primaryUser == null){

                this.waitingMessageTextView.setVisibility(View.GONE);

                this.primaryUser = user;
                userCanvas.subscribe(this.primaryVideoView,
                        ZoomVideoSDKVideoAspect.ZoomVideoSDKVideoAspect_PanAndScan,
                        ZoomVideoSDKVideoResolution.ZoomVideoSDKResolution_Auto);
            } else if (this.secondaryThumbnailUser == null) {
                // In this case, the user will be in the secondary thumbnail if it is available.
                this.secondaryThumbnailVideoView.setVisibility(View.VISIBLE);
                this.secondaryThumbnailUser = user;
                userCanvas.subscribe(this.secondaryThumbnailVideoView,
                        ZoomVideoSDKVideoAspect.ZoomVideoSDKVideoAspect_PanAndScan,
                        ZoomVideoSDKVideoResolution.ZoomVideoSDKResolution_Auto);
            }
        }
    }

    @Override
    public void onUserLeave(ZoomVideoSDKUserHelper userHelper, List<ZoomVideoSDKUser> userList) {
        for (ZoomVideoSDKUser user : userList) {
            if (this.primaryUser != null && this.primaryUser.getUserID().equals(user.getUserID())) {
                // Remove the user from primary view.
                this.primaryUser = null;
                user.getVideoCanvas().unSubscribe(this.primaryVideoView);

                if (this.secondaryThumbnailUser != null) {
                    // Move the secondary thumbnail user to the primary view.
                    this.secondaryThumbnailUser.getVideoCanvas().unSubscribe(this.secondaryThumbnailVideoView);
                    this.secondaryThumbnailVideoView.setVisibility(View.GONE);

                    this.primaryUser = this.secondaryThumbnailUser;
                    this.secondaryThumbnailUser = null;

                    this.primaryUser.getVideoCanvas().subscribe(this.primaryVideoView,
                            ZoomVideoSDKVideoAspect.ZoomVideoSDKVideoAspect_PanAndScan,
                            ZoomVideoSDKVideoResolution.ZoomVideoSDKResolution_Auto);
                } else {
                    this.waitingMessageTextView.setVisibility(View.VISIBLE);
                }

            } else if (this.secondaryThumbnailUser != null && this.secondaryThumbnailUser.getUserID().equals(user.getUserID())) {
                this.secondaryThumbnailUser.getVideoCanvas().unSubscribe(this.secondaryThumbnailVideoView);
                this.secondaryThumbnailVideoView.setVisibility(View.GONE);
                this.secondaryThumbnailUser = null;
            }
        }
    }

    @Override
    public void onUserVideoStatusChanged(ZoomVideoSDKVideoHelper videoHelper, List<ZoomVideoSDKUser> userList) {

    }

    @Override
    public void onUserAudioStatusChanged(ZoomVideoSDKAudioHelper audioHelper, List<ZoomVideoSDKUser> userList) {

    }

    @Override
    public void onUserShareStatusChanged(ZoomVideoSDKShareHelper shareHelper, ZoomVideoSDKUser userInfo, ZoomVideoSDKShareStatus status) {

    }

    @Override
    public void onLiveStreamStatusChanged(ZoomVideoSDKLiveStreamHelper liveStreamHelper, ZoomVideoSDKLiveStreamStatus status) {

    }

    @Override
    public void onChatNewMessageNotify(ZoomVideoSDKChatHelper chatHelper, ZoomVideoSDKChatMessage messageItem) {

    }

    @Override
    public void onChatDeleteMessageNotify(ZoomVideoSDKChatHelper chatHelper, String msgID, ZoomVideoSDKChatMessageDeleteType deleteBy) {

    }

    @Override
    public void onChatPrivilegeChanged(ZoomVideoSDKChatHelper chatHelper, ZoomVideoSDKChatPrivilegeType currentPrivilege) {

    }

    @Override
    public void onUserHostChanged(ZoomVideoSDKUserHelper userHelper, ZoomVideoSDKUser userInfo) {

    }

    @Override
    public void onUserManagerChanged(ZoomVideoSDKUser user) {

    }

    @Override
    public void onUserNameChanged(ZoomVideoSDKUser user) {

    }

    @Override
    public void onUserActiveAudioChanged(ZoomVideoSDKAudioHelper audioHelper, List<ZoomVideoSDKUser> list) {

    }

    @Override
    public void onSessionNeedPassword(ZoomVideoSDKPasswordHandler handler) {

    }

    @Override
    public void onSessionPasswordWrong(ZoomVideoSDKPasswordHandler handler) {

    }

    @Override
    public void onMixedAudioRawDataReceived(ZoomVideoSDKAudioRawData rawData) {

    }

    @Override
    public void onOneWayAudioRawDataReceived(ZoomVideoSDKAudioRawData rawData, ZoomVideoSDKUser user) {

    }

    @Override
    public void onShareAudioRawDataReceived(ZoomVideoSDKAudioRawData rawData) {

    }

    @Override
    public void onCommandReceived(ZoomVideoSDKUser sender, String strCmd) {

    }

    @Override
    public void onCommandChannelConnectResult(boolean isSuccess) {

    }

    @Override
    public void onCloudRecordingStatus(ZoomVideoSDKRecordingStatus status, ZoomVideoSDKRecordingConsentHandler handler) {

    }

    @Override
    public void onHostAskUnmute() {

    }

    @Override
    public void onInviteByPhoneStatus(ZoomVideoSDKPhoneStatus status, ZoomVideoSDKPhoneFailedReason reason) {

    }

    @Override
    public void onMultiCameraStreamStatusChanged(ZoomVideoSDKMultiCameraStreamStatus status, ZoomVideoSDKUser user, ZoomVideoSDKRawDataPipe videoPipe) {

    }

    @Override
    public void onMultiCameraStreamStatusChanged(ZoomVideoSDKMultiCameraStreamStatus status, ZoomVideoSDKUser user, ZoomVideoSDKVideoCanvas canvas) {

    }

    @Override
    public void onLiveTranscriptionStatus(ZoomVideoSDKLiveTranscriptionHelper.ZoomVideoSDKLiveTranscriptionStatus status) {

    }

    @Override
    public void onLiveTranscriptionMsgReceived(String ltMsg, ZoomVideoSDKUser pUser, ZoomVideoSDKLiveTranscriptionHelper.ZoomVideoSDKLiveTranscriptionOperationType type) {

    }

    @Override
    public void onOriginalLanguageMsgReceived(ZoomVideoSDKLiveTranscriptionHelper.ILiveTranscriptionMessageInfo messageInfo) {

    }

    @Override
    public void onLiveTranscriptionMsgInfoReceived(ZoomVideoSDKLiveTranscriptionHelper.ILiveTranscriptionMessageInfo messageInfo) {

    }

    @Override
    public void onLiveTranscriptionMsgError(ZoomVideoSDKLiveTranscriptionHelper.ILiveTranscriptionLanguage spokenLanguage, ZoomVideoSDKLiveTranscriptionHelper.ILiveTranscriptionLanguage transcriptLanguage) {

    }

    @Override
    public void onProxySettingNotification(ZoomVideoSDKProxySettingHandler handler) {

    }

    @Override
    public void onSSLCertVerifiedFailNotification(ZoomVideoSDKSSLCertificateInfo info) {

    }

    @Override
    public void onCameraControlRequestResult(ZoomVideoSDKUser user, boolean isApproved) {

    }

    @Override
    public void onUserVideoNetworkStatusChanged(ZoomVideoSDKNetworkStatus status, ZoomVideoSDKUser user) {

    }

    @Override
    public void onUserRecordingConsent(ZoomVideoSDKUser user) {

    }

    @Override
    public void onCallCRCDeviceStatusChanged(ZoomVideoSDKCRCCallStatus status) {

    }

    @Override
    public void onVideoCanvasSubscribeFail(ZoomVideoSDKVideoSubscribeFailReason fail_reason, ZoomVideoSDKUser pUser, ZoomVideoSDKVideoView view) {

    }

    @Override
    public void onShareCanvasSubscribeFail(ZoomVideoSDKVideoSubscribeFailReason fail_reason, ZoomVideoSDKUser pUser, ZoomVideoSDKVideoView view) {

    }

    @Override
    public void onAnnotationHelperCleanUp(ZoomVideoSDKAnnotationHelper helper) {

    }

    @Override
    public void onAnnotationPrivilegeChange(boolean enable, ZoomVideoSDKUser shareOwner) {

    }

    @Override
    public void onTestMicStatusChanged(ZoomVideoSDKTestMicStatus status) {

    }

    @Override
    public void onMicSpeakerVolumeChanged(int micVolume, int speakerVolume) {

    }
}
