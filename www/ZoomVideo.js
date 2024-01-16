var exec = require('cordova/exec');
var PLUGIN_NAME = "ZoomVideo";

function callNativeFunction(name, args, success, error) {
    success = success || function(){};
    error = error || function(){};
    args = args || [];
    exec(success, error, PLUGIN_NAME, name, args);
}

var zoom = {
    openSession: function(sdkKey, sdkSecret, sessionName, sessionKey, userIdentity, roleType, success, error) {
        callNativeFunction('openSession', [sdkKey, sdkSecret, sessionName, sessionKey, userIdentity, roleType], success, error);
    }
};

module.exports = zoom;