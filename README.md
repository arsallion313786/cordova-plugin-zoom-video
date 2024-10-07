For iOS We have added Feature
1. Picture in Picture
2. Chat
3. ScreenSharing


We have added Picture in Picture Feature so min iOS version should be 16.0 otherwise you will get errors.
In main target you need to set min iOS version 16.0 and as well as  in Cordova Lib target for both CordvaLib and framework.
In Main app target you need to select Build Setting than search Swift Language there you need to select swift version 5.0.

For ScreenSharing:
1. you need to add Broadcast Upload extension in main app target. You can give any name but for suggestion give ScreenShare. During creation select objective-C language and uncheck upload Broadcast extenion UI option.
2. Here alos set min iOS version 16.0.
3. you need app group ID 
4. you need to enable group id in both Application  and ShareScreen Provisioning profile
5. In both targets in Signing Capabilities you need to add App Group and select group id that you have ceated in step 3
6. For Picture in Picture In Main App target you also need to add Backgroung Mode and check Audio, Airplay and Picture in Picture and Voice over Viop option
7. In ShareSceen, You need to add SampleHandler.h and SampleHandler.mm files. These files already added in plugin. You can add from there.
8. In ShareSceen, You need to add ZoomVideoSDK.ScreenShare framework and set Do not embed option (This frameworl already added in plugin you can find from ios/src folder)
9. In ShareSceen, You need to add build in CoreMedia, CoreVideo, CoreGraphic and VideoToolbox frameworks
10.  In ShareSceen, In SampleHandler.mm, you need to give app group id that you have created in STEp-3.

Plugin Configuration:<br>
You can add plugin with command
cordova plugin add --link https://github.com/arsallion313786/cordova-plugin-zoom-video

You can call this function to Start Zoom Vidoe Session
cordova.plugins.ZoomVideo.openSession({jwt token},
        "{sessoin name}",
        "{user name}",
        "{domain}",
        (enable log bool value),
        "{app group id}",
        "{share extension bundle identifier}",
         "waiting for someone to join",
         () => {},
          () =>{},
        );










