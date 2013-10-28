function fri(){
  var $wnd_0 = window;
  var $doc_0 = document;
  sendStats('bootstrap', 'begin');
  function isHostedMode(){
    var query = $wnd_0.location.search;
    return query.indexOf('gwt.codesvr.fri=') != -1 || query.indexOf('gwt.codesvr=') != -1;
  }

  function sendStats(evtGroupString, typeString){
    if ($wnd_0.__gwtStatsEvent) {
      $wnd_0.__gwtStatsEvent({moduleName:'fri', sessionId:$wnd_0.__gwtStatsSessionId, subSystem:'startup', evtGroup:evtGroupString, millis:(new Date).getTime(), type:typeString});
    }
  }

  fri.__sendStats = sendStats;
  fri.__moduleName = 'fri';
  fri.__errFn = null;
  fri.__moduleBase = 'DUMMY';
  fri.__softPermutationId = 0;
  fri.__computePropValue = null;
  var __gwt_isKnownPropertyValue = function(){
    return false;
  }
  ;
  var __gwt_getMetaProperty = function(){
    return null;
  }
  ;
  __propertyErrorFunction = null;
  function installScript(filename){
    var frameDoc;
    function getInstallLocationDoc(){
      setupInstallLocation();
      return frameDoc;
    }

    function getInstallLocation(){
      setupInstallLocation();
      return frameDoc.getElementsByTagName('body')[0];
    }

    function setupInstallLocation(){
      if (frameDoc) {
        return;
      }
      var scriptFrame = $doc_0.createElement('iframe');
      scriptFrame.src = 'javascript:""';
      scriptFrame.id = 'fri';
      scriptFrame.style.cssText = 'position:absolute; width:0; height:0; border:none; left: -1000px; top: -1000px; !important';
      scriptFrame.tabIndex = -1;
      $doc_0.body.appendChild(scriptFrame);
      frameDoc = scriptFrame.contentDocument;
      if (!frameDoc) {
        frameDoc = scriptFrame.contentWindow.document;
      }
      frameDoc.open();
      frameDoc.write('<html><head><\/head><body><\/body><\/html>');
      frameDoc.close();
      var frameDocbody = frameDoc.getElementsByTagName('body')[0];
      var script = frameDoc.createElement('script');
      script.language = 'javascript';
      var temp = 'var $wnd = window.parent;';
      script.text = temp;
      frameDocbody.appendChild(script);
    }

    function setupWaitForBodyLoad(callback){
      function isBodyLoaded(){
        if (typeof $doc_0.readyState == 'undefined') {
          return typeof $doc_0.body != 'undefined' && $doc_0.body != null;
        }
        return /loaded|complete/.test($doc_0.readyState);
      }

      var bodyDone = false;
      if (isBodyLoaded()) {
        bodyDone = true;
        callback();
      }
      var onBodyDoneTimerId;
      function onBodyDone(){
        if (!bodyDone) {
          bodyDone = true;
          callback();
          if ($doc_0.removeEventListener) {
            $doc_0.removeEventListener('DOMContentLoaded', onBodyDone, false);
          }
          if (onBodyDoneTimerId) {
            clearInterval(onBodyDoneTimerId);
          }
        }
      }

      if ($doc_0.addEventListener) {
        $doc_0.addEventListener('DOMContentLoaded', function(){
          onBodyDone();
        }
        , false);
      }
      var onBodyDoneTimerId = setInterval(function(){
        if (isBodyLoaded()) {
          onBodyDone();
        }
      }
      , 50);
    }

    function installCode(code){
      var docbody = getInstallLocation();
      var script = getInstallLocationDoc().createElement('script');
      script.language = 'javascript';
      script.text = code;
      docbody.appendChild(script);
    }

    fri.onScriptDownloaded = function(code){
      setupWaitForBodyLoad(function(){
        installCode(code);
      }
      );
    }
    ;
    sendStats('moduleStartup', 'moduleRequested');
    var script_0 = $doc_0.createElement('script');
    script_0.src = filename;
    $doc_0.getElementsByTagName('head')[0].appendChild(script_0);
  }

  function processMetas(){
    var metaProps = {};
    var propertyErrorFunc;
    var onLoadErrorFunc;
    var metas = $doc_0.getElementsByTagName('meta');
    for (var i_0 = 0, n = metas.length; i_0 < n; ++i_0) {
      var meta = metas[i_0], name_1 = meta.getAttribute('name'), content_0;
      if (name_1) {
        name_1 = name_1.replace('fri::', '');
        if (name_1.indexOf('::') >= 0) {
          continue;
        }
        if (name_1 == 'gwt:property') {
          content_0 = meta.getAttribute('content');
          if (content_0) {
            var value_0, eq = content_0.indexOf('=');
            if (eq >= 0) {
              name_1 = content_0.substring(0, eq);
              value_0 = content_0.substring(eq + 1);
            }
             else {
              name_1 = content_0;
              value_0 = '';
            }
            metaProps[name_1] = value_0;
          }
        }
         else if (name_1 == 'gwt:onPropertyErrorFn') {
          content_0 = meta.getAttribute('content');
          if (content_0) {
            try {
              propertyErrorFunc = eval(content_0);
            }
             catch (e) {
              alert('Bad handler "' + content_0 + '" for "gwt:onPropertyErrorFn"');
            }
          }
        }
         else if (name_1 == 'gwt:onLoadErrorFn') {
          content_0 = meta.getAttribute('content');
          if (content_0) {
            try {
              onLoadErrorFunc = eval(content_0);
            }
             catch (e) {
              alert('Bad handler "' + content_0 + '" for "gwt:onLoadErrorFn"');
            }
          }
        }
      }
    }
    __gwt_getMetaProperty = function(name_0){
      var value = metaProps[name_0];
      return value == null?null:value;
    }
    ;
    __propertyErrorFunction = propertyErrorFunc;
    fri.__errFn = onLoadErrorFunc;
  }

  function computeScriptBase(){
    function getDirectoryOfFile(path){
      var hashIndex = path.lastIndexOf('#');
      if (hashIndex == -1) {
        hashIndex = path.length;
      }
      var queryIndex = path.indexOf('?');
      if (queryIndex == -1) {
        queryIndex = path.length;
      }
      var slashIndex = path.lastIndexOf('/', Math.min(queryIndex, hashIndex));
      return slashIndex >= 0?path.substring(0, slashIndex + 1):'';
    }

    function ensureAbsoluteUrl(url){
      if (url.match(/^\w+:\/\//)) {
      }
       else {
        var img = $doc_0.createElement('img');
        img.src = url + 'clear.cache.gif';
        url = getDirectoryOfFile(img.src);
      }
      return url;
    }

    function tryMetaTag(){
      var metaVal = __gwt_getMetaProperty('baseUrl');
      if (metaVal != null) {
        return metaVal;
      }
      return '';
    }

    function tryNocacheJsTag(){
      var scriptTags = $doc_0.getElementsByTagName('script');
      for (var i_0 = 0; i_0 < scriptTags.length; ++i_0) {
        if (scriptTags[i_0].src.indexOf('fri.nocache.js') != -1) {
          return getDirectoryOfFile(scriptTags[i_0].src);
        }
      }
      return '';
    }

    function tryBaseTag(){
      var baseElements = $doc_0.getElementsByTagName('base');
      if (baseElements.length > 0) {
        return baseElements[baseElements.length - 1].href;
      }
      return '';
    }

    var tempBase = tryMetaTag();
    if (tempBase == '') {
      tempBase = tryNocacheJsTag();
    }
    if (tempBase == '') {
      tempBase = tryBaseTag();
    }
    if (tempBase == '') {
      tempBase = getDirectoryOfFile($doc_0.location.href);
    }
    tempBase = ensureAbsoluteUrl(tempBase);
    return tempBase;
  }

  function computeUrlForResource(resource){
    if (resource.match(/^\//)) {
      return resource;
    }
    if (resource.match(/^[a-zA-Z]+:\/\//)) {
      return resource;
    }
    return fri.__moduleBase + resource;
  }

  function getCompiledCodeFilename(){
    var answers = [];
    var softPermutationId;
    function unflattenKeylistIntoAnswers(propValArray, value){
      var answer = answers;
      for (var i_0 = 0, n = propValArray.length - 1; i_0 < n; ++i_0) {
        answer = answer[propValArray[i_0]] || (answer[propValArray[i_0]] = []);
      }
      answer[propValArray[n]] = value;
    }

    var values = [];
    var providers = [];
    function computePropValue(propName){
      var value = providers[propName](), allowedValuesMap = values[propName];
      if (value in allowedValuesMap) {
        return value;
      }
      var allowedValuesList = [];
      for (var k in allowedValuesMap) {
        allowedValuesList[allowedValuesMap[k]] = k;
      }
      if (__propertyErrorFunc) {
        __propertyErrorFunc(propName, allowedValuesList, value);
      }
      throw null;
    }

    providers['log_level'] = function(){
      var log_level;
      if (log_level == null) {
        var regex = new RegExp('[\\?&]log_level=([^&#]*)');
        var results = regex.exec(location.search);
        if (results != null) {
          log_level = results[1];
        }
      }
      if (log_level == null) {
        log_level = __gwt_getMetaProperty('log_level');
      }
      if (!__gwt_isKnownPropertyValue('log_level', log_level)) {
        var levels = ['TRACE', 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL', 'OFF'];
        var possibleLevel = null;
        var foundRequestedLevel = false;
        for (i in levels) {
          foundRequestedLevel |= log_level == levels[i];
          if (__gwt_isKnownPropertyValue('log_level', levels[i])) {
            possibleLevel = levels[i];
          }
          if (i == levels.length - 1 || foundRequestedLevel && possibleLevel != null) {
            log_level = possibleLevel;
            break;
          }
        }
      }
      return log_level;
    }
    ;
    values['log_level'] = {DEBUG:0, INFO:1};
    providers['mobile.user.agent'] = function(){
      return /(android|iphone|ipod|ipad)/i.test(window.navigator.userAgent)?'mobilesafari':'not_mobile';
    }
    ;
    values['mobile.user.agent'] = {mobilesafari:0, not_mobile:1};
    providers['user.agent'] = function(){
      var ua = navigator.userAgent.toLowerCase();
      var makeVersion = function(result){
        return parseInt(result[1]) * 1000 + parseInt(result[2]);
      }
      ;
      if (function(){
        return ua.indexOf('opera') != -1;
      }
      ())
        return 'opera';
      if (function(){
        return ua.indexOf('webkit') != -1 || function(){
          if (ua.indexOf('chromeframe') != -1) {
            return true;
          }
          if (typeof window['ActiveXObject'] != 'undefined') {
            try {
              var obj = new ActiveXObject('ChromeTab.ChromeFrame');
              if (obj) {
                obj.registerBhoIfNeeded();
                return true;
              }
            }
             catch (e) {
            }
          }
          return false;
        }
        ();
      }
      ())
        return 'safari';
      if (function(){
        return ua.indexOf('msie') != -1 && $doc_0.documentMode >= 9;
      }
      ())
        return 'ie9';
      if (function(){
        return ua.indexOf('msie') != -1 && $doc_0.documentMode >= 8;
      }
      ())
        return 'ie8';
      if (function(){
        var result = /msie ([0-9]+)\.([0-9]+)/.exec(ua);
        if (result && result.length == 3)
          return makeVersion(result) >= 6000;
      }
      ())
        return 'ie6';
      if (function(){
        return ua.indexOf('gecko') != -1;
      }
      ())
        return 'gecko1_8';
      return 'unknown';
    }
    ;
    values['user.agent'] = {gecko1_8:0, ie6:1, ie8:2, ie9:3, opera:4, safari:5};
    __gwt_isKnownPropertyValue = function(propName, propValue){
      return propValue in values[propName];
    }
    ;
    fri.__computePropValue = computePropValue;
    sendStats('bootstrap', 'selectingPermutation');
    if (isHostedMode()) {
      return computeUrlForResource('fri.devmode.js');
    }
    var strongName;
    try {
      unflattenKeylistIntoAnswers(['DEBUG', 'not_mobile', 'gecko1_8'], '10E39A3FC0A1EC4D8C14921FDE5F4DB1');
      unflattenKeylistIntoAnswers(['DEBUG', 'mobilesafari', 'safari'], '24C4E689E2D9F738F0F41CC984D35697');
      unflattenKeylistIntoAnswers(['INFO', 'not_mobile', 'gecko1_8'], '31272E23811E81BE1DF8A1032068DDCA');
      unflattenKeylistIntoAnswers(['INFO', 'not_mobile', 'safari'], '466CD67F025DBBD77106933CC61EBD55');
      unflattenKeylistIntoAnswers(['DEBUG', 'not_mobile', 'safari'], '49C4659DF4B08EDE21006DA2103FFC3B');
      unflattenKeylistIntoAnswers(['DEBUG', 'not_mobile', 'ie9'], '9083E7CA8923FB0F1218DE7AF62D0AE2');
      unflattenKeylistIntoAnswers(['INFO', 'mobilesafari', 'safari'], '9AD2EEC29B694213A2BB805DD86B7BD2');
      unflattenKeylistIntoAnswers(['INFO', 'not_mobile', 'ie9'], 'A5BEA5477CFD12EECBBA7343B3D035AA');
      strongName = answers[computePropValue('log_level')][computePropValue('mobile.user.agent')][computePropValue('user.agent')];
      var idx = strongName.indexOf(':');
      if (idx != -1) {
        softPermutationId = strongName.substring(idx + 1);
        strongName = strongName.substring(0, idx);
      }
    }
     catch (e) {
    }
    fri.__softPermutationId = softPermutationId;
    return computeUrlForResource(strongName + '.cache.js');
  }

  function loadExternalStylesheets(){
    if (!$wnd_0.__gwt_stylesLoaded) {
      $wnd_0.__gwt_stylesLoaded = {};
    }
    function installOneStylesheet(stylesheetUrl){
      if (!__gwt_stylesLoaded[stylesheetUrl]) {
        var l = $doc_0.createElement('link');
        l.setAttribute('rel', 'stylesheet');
        l.setAttribute('href', computeUrlForResource(stylesheetUrl));
        $doc_0.getElementsByTagName('head')[0].appendChild(l);
        __gwt_stylesLoaded[stylesheetUrl] = true;
      }
    }

    sendStats('loadExternalRefs', 'begin');
    installOneStylesheet('gwt/standard/standard.css');
    sendStats('loadExternalRefs', 'end');
  }

  processMetas();
  fri.__moduleBase = computeScriptBase();
  var filename_0 = getCompiledCodeFilename();
  loadExternalStylesheets();
  sendStats('bootstrap', 'end');
  installScript(filename_0);
}

fri();
