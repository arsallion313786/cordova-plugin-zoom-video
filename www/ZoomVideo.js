cordova.define("cordova.plugin.zoomvideo.ZoomVideo", function(require, exports, module) {
    var exec = require('cordova/exec');
    var PLUGIN_NAME = "ZoomVideo";

    function callNativeFunction(name, args, success, error) {
        success = success || function(){};
        error = error || function(){};
        args = args || [];
        exec(success, error, PLUGIN_NAME, name, args);
    }

    var zoom = {
        openSession: function(jwtToken, sessionName, userName, domain, enableLog, success, error) {
            callNativeFunction('openSession', [jwtToken, sessionName, userName, domain, enableLog], success, error);
        }
    };

    module.exports = zoom;
});