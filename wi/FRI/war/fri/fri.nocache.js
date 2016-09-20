<<<<<<< Updated upstream
/*
 * Copyright 2014 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/**
 * This startup script is used when we run superdevmode from an app server.
 *
 * The main goal is to avoid installing bookmarklets for host:port/module
 * to load and recompile the application.
 */
(function($wnd, $doc){
  // Don't support browsers without session storage: IE6/7
  var badBrowser = 'Unable to load Super Dev Mode of "fri" because\n';
  if (!('sessionStorage' in $wnd)) {
    $wnd.alert(badBrowser +  'this browser does not support "sessionStorage".');
    return;
  }

  //We don't import properties.js so we have to update active modules here
  $wnd.__gwt_activeModules = $wnd.__gwt_activeModules || {};
  $wnd.__gwt_activeModules['fri'] = {
    'moduleName' : 'fri',
    'bindings' : function() {
      return {};
    }
  };

  // Reuse compute script base
  /*
 * Copyright 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/**
 * A simplified version of computeScriptBase.js that's used only when running
 * in Super Dev Mode. (We don't want the default version because it allows the
 * web page to override it using a meta tag.)
 *
 * Prerequisite: we assume that the first script tag using a URL ending with
 * "/fri.nocache.js" is the one that loaded us. Normally this happens
 * because DevModeRedirectHook.js loaded this nocache.js script by prepending a
 * script tag with an absolute URL to head. (However, it's also okay for an html
 * file included in the GWT compiler's output to load the nocache.js file using
 * a relative URL.)
 */
function computeScriptBase() {
  // TODO(skybrian) This approach won't work for workers.

  $wnd.__gwt_activeModules['fri'].superdevmode = true;

  var expectedSuffix = '/fri.nocache.js';

  var scriptTags = $doc.getElementsByTagName('script');
  for (var i = 0;; i++) {
    var tag = scriptTags[i];
    if (!tag) {
      break;
    }
    var candidate = tag.src;
    var lastMatch = candidate.lastIndexOf(expectedSuffix);
    if (lastMatch == candidate.length - expectedSuffix.length) {
      // Assumes that either the URL is absolute, or it's relative
      // and the html file is hosted by this code server.
      return candidate.substring(0, lastMatch + 1);
    }
  }

  $wnd.alert('Unable to load Super Dev Mode version of ' + fri + ".");
}
;

  // document.head does not exist in IE8
  var $head = $doc.head || $doc.getElementsByTagName('head')[0];

  // Quick way to compute the user.agent, it works almost the same than
  // UserAgentPropertyGenerator, but we cannot reuse it without depending
  // on gwt-user.jar.
  // This reduces compilation time since we only compile for one ua.
  var ua = $wnd.navigator.userAgent.toLowerCase();
  var docMode = $doc.documentMode || 0;
  ua = /webkit/.test(ua)? 'safari' : /gecko/.test(ua) || docMode > 10 ? 'gecko1_8' :
       /msie/.test(ua) && docMode > 7 ? 'ie' + docMode : '';
  if (!ua && docMode) {
    $wnd.alert(badBrowser +  'your browser is running "Compatibility View" for IE' + docMode + '.');
    return;
  }

  // We use a different key for each module so that we can turn on dev mode
  // independently for each.
  var devModeHookKey = '__gwtDevModeHook:fri';
  var devModeSessionKey = '__gwtDevModeSession:fri';

  // Compute some codeserver urls so as the user does not need bookmarklets
  var hostName = $wnd.location.hostname;
  var serverUrl = 'http://' + hostName + ':9876';
  var nocacheUrl = serverUrl + '/fri/fri.nocache.js';

  // Save supder-devmode url in session
  $wnd.sessionStorage[devModeHookKey] = nocacheUrl;
  // Save user.agent in session
  $wnd.sessionStorage[devModeSessionKey] = 'user.agent=' + ua + '&';

  // Set bookmarklet params in window
  $wnd.__gwt_bookmarklet_params = {'server_url': serverUrl};
  // Save the original module base. (Returned by GWT.getModuleBaseURL.)
  $wnd[devModeHookKey + ':moduleBase'] = computeScriptBase();

  // Needed in the real nocache.js logic
  $wnd.__gwt_activeModules['fri'].canRedirect = true;
  $wnd.__gwt_activeModules['fri'].superdevmode = true;

  // Insert the superdevmode nocache script in the first position of the head
  var devModeScript = $doc.createElement('script');
  devModeScript.src = nocacheUrl;

  // Show a div in a corner for adding buttons to recompile the app.
  // We reuse the same div in all modules of this page for stacking buttons
  // and to make it available in jsni.
  // The user can remove this: .gwt-DevModeRefresh {display:none}
  $wnd.__gwt_compileElem = $wnd.__gwt_compileElem || $doc.createElement('div');
  $wnd.__gwt_compileElem.className = 'gwt-DevModeRefresh';

  // Create the compile button for this module
  var compileButton = $doc.createElement('div');
  $wnd.__gwt_compileElem.appendChild(compileButton);
  // Number of modules present in the window
  var moduleIdx = $wnd.__gwt_compileElem.childNodes.length;
  // Each button has a class with its index number
  var buttonClassName = 'gwt-DevModeCompile gwt-DevModeModule-' + moduleIdx;
  compileButton.className = buttonClassName;
  // The status message container
  compileButton.innerHTML = '<div></div>';
  // User knows who module to compile, hovering the button
  compileButton.title = 'Compile module:\nfri';

  // Use CSS so the app could change button style
  var compileStyle = $doc.createElement('style');
  compileStyle.language = 'text/css';
  $head.appendChild(compileStyle);
  var css =
    ".gwt-DevModeRefresh{" +
      "position:fixed;" +
      "right:3px;" +
      "bottom:3px;" +
      "font-family:arial;" +
      "font-size:1.8em;" +
      "cursor:pointer;" +
      "color:#B62323;" +
      "text-shadow:grey 1px 1px 3px;" +
      "z-index:2147483646;" +
      "white-space:nowrap;" +
    "}" +
    ".gwt-DevModeCompile{" +
      "position:relative;" +
      "float:left;" +
      "width:1em;" +
    "}" +
    ".gwt-DevModeCompile div{" +
      "position:absolute;" +
      "right:1em;" +
      "bottom:-3px;" +
      "font-size:0.3em;" +
      "opacity:1;" +
      "direction:rtl;" +
    "}" +
    ".gwt-DevModeCompile:before{" +
      "content:'\u21bb';" +
    "}" +
    ".gwt-DevModeCompiling:before{" +
      // IE8 fails when setting content here
      "opacity:0.1;" +
    "}" +
    ".gwt-DevModeCompile div:before{" +
      "content:'GWT';" +
    "}" +
    ".gwt-DevModeError div:before{" +
      "content:'FAILED';" +
    "}";
  // Only insert common css the first time
  css = (moduleIdx == 1 ? css : '') +
    ".gwt-DevModeModule-" + moduleIdx + ".gwt-DevModeCompiling div:before{" +
      "content:'COMPILING fri';" +
      "font-size:24px;" +
      "color:#d2d9ee;" +
    "}";
  if ('styleSheet' in compileStyle) {
    // IE8
    compileStyle.styleSheet.cssText = css;
  } else {
    compileStyle.appendChild($doc.createTextNode(css));
  }

  // Set a different compile function name per module
  var compileFunction = '__gwt_compile_' + moduleIdx;

  compileButton.onclick = function() {
    $wnd[compileFunction]();
  };

  // defer so as the body is ready
  setTimeout(function(){
    $head.insertBefore(devModeScript, $head.firstElementChild || $head.children[0]);
    $doc.body.appendChild($wnd.__gwt_compileElem);
  }, 1);

  // Flag to avoid compiling in parallel.
  var compiling = false;
  // Compile function available in window so as it can be run from jsni.
  // TODO(manolo): make Super Dev Mode script set this function in __gwt_activeModules
  $wnd[compileFunction] = function() {
    if (compiling) {
      return;
    }
    compiling = true;

    // Compute an unique name for each callback to avoid cache issues
    // in IE, and to avoid the same function being called twice.
    var callback = '__gwt_compile_callback_' + moduleIdx + '_' + new Date().getTime();
    $wnd[callback] = function(r) {
      if (r && r.status && r.status == 'ok') {
        $wnd.location.reload();
      }
      compileButton.className = buttonClassName + ' gwt-DevModeError';
      delete $wnd[callback];
      compiling = false;
    };

    // Insert the jsonp script to compile the current module
    // TODO(manolo): we don't have a way to detect when the server is unreachable,
    // maybe a request returning status='idle'
    var compileScript = $doc.createElement('script');
    compileScript.src = serverUrl +
      '/recompile/fri?user.agent=' + ua + '&_callback=' + callback;
    $head.appendChild(compileScript);
    compileButton.className = buttonClassName  + ' gwt-DevModeCompiling';
  }

  // Run this block after the app has been loaded.
  setTimeout(function(){
    // Maintaining the hook key in session can cause problems
    // if we try to run classic code server so we remove it
    // after a while.
    $wnd.sessionStorage.removeItem(devModeHookKey);

    // Re-attach compile button because sometimes app clears the dom
    $doc.body.appendChild($wnd.__gwt_compileElem);
  }, 2000);
})(window, document);
=======
function fri(){var V='',S=' top: -1000px;',qb='" for "gwt:onLoadErrorFn"',ob='" for "gwt:onPropertyErrorFn"',_='");',rb='#',gc='.cache.js',tb='/',zb='//',Zb='4041D58C3AB53BA100C9B777062D543F',$b='65BCEBB080B0F1DC2A88FCE62DE6BEB4',_b='832F37C7242EA37059D4D91AFCB1679D',fc=':',ib='::',U='<!doctype html>',W='<html><head><\/head><body><\/body><\/html>',lb='=',sb='?',ac='A6112C414F902CB8FE95AB203273E42E',nb='Bad handler "',bc='CAF9A268F4BFB6F667789AAB0B10CCFF',cc='CF6D709975A2734BE751E618B36AD8EC',T='CSS1Compat',Z='Chrome',dc='DACC282E8111AFA157D95EDCEE523D30',ec='DCCCCEF06422672F68BED1760292F33D',Db='DEBUG',Y='DOMContentLoaded',N='DUMMY',Gb='ERROR',Hb='FATAL',Eb='INFO',Ib='OFF',Cb='TRACE',Fb='WARN',Bb='[\\?&]log_level=([^&#]*)',yb='base',wb='baseUrl',I='begin',O='body',H='bootstrap',vb='clear.cache.gif',kb='content',nc='end',$='eval("',L='fri',Yb='fri.devmode.js',xb='fri.nocache.js',hb='fri::',Ub='gecko',Vb='gecko1_8',J='gwt.codesvr.fri=',K='gwt.codesvr=',mc='gwt/standard/standard.css',pb='gwt:onLoadErrorFn',mb='gwt:onPropertyErrorFn',jb='gwt:property',eb='head',kc='href',Tb='ie6',Sb='ie8',Rb='ie9',P='iframe',ub='img',bb='javascript',Q='javascript:""',hc='link',lc='loadExternalRefs',Ab='log_level',fb='meta',Jb='mobile.user.agent',Kb='mobilesafari',db='moduleRequested',cb='moduleStartup',Qb='msie',gb='name',Lb='not_mobile',Nb='opera',R='position:absolute; width:0; height:0; border:none; left: -1000px;',ic='rel',Pb='safari',ab='script',Xb='selectingPermutation',M='startup',jc='stylesheet',X='undefined',Wb='unknown',Mb='user.agent',Ob='webkit';var p=window;var q=document;s(H,I);function r(){var a=p.location.search;return a.indexOf(J)!=-1||a.indexOf(K)!=-1}
function s(a,b){if(p.__gwtStatsEvent){p.__gwtStatsEvent({moduleName:L,sessionId:p.__gwtStatsSessionId,subSystem:M,evtGroup:a,millis:(new Date).getTime(),type:b})}}
fri.__sendStats=s;fri.__moduleName=L;fri.__errFn=null;fri.__moduleBase=N;fri.__softPermutationId=0;fri.__computePropValue=null;fri.__getPropMap=null;fri.__gwtInstallCode=function(){};fri.__gwtStartLoadingFragment=function(){return null};var t=function(){return false};var u=function(){return null};__propertyErrorFunction=null;var v=p.__gwt_activeModules=p.__gwt_activeModules||{};v[L]={moduleName:L};var w;function x(){z();return w}
function y(){z();return w.getElementsByTagName(O)[0]}
function z(){if(w){return}var a=q.createElement(P);a.src=Q;a.id=L;a.style.cssText=R+S;a.tabIndex=-1;q.body.appendChild(a);w=a.contentDocument;if(!w){w=a.contentWindow.document}w.open();var b=document.compatMode==T?U:V;w.write(b+W);w.close()}
function A(l){function m(a){function b(){if(typeof q.readyState==X){return typeof q.body!=X&&q.body!=null}return /loaded|complete/.test(q.readyState)}
var c=b();if(c){a();return}function d(){if(!c){c=true;a();if(q.removeEventListener){q.removeEventListener(Y,d,false)}if(e){clearInterval(e)}}}
if(q.addEventListener){q.addEventListener(Y,d,false)}var e=setInterval(function(){if(b()){d()}},50)}
function n(c){function d(a,b){a.removeChild(b)}
var e=y();var f=x();var g;if(navigator.userAgent.indexOf(Z)>-1&&window.JSON){var h=f.createDocumentFragment();h.appendChild(f.createTextNode($));for(var j=0;j<c.length;j++){var k=window.JSON.stringify(c[j]);h.appendChild(f.createTextNode(k.substring(1,k.length-1)))}h.appendChild(f.createTextNode(_));g=f.createElement(ab);g.language=bb;g.appendChild(h);e.appendChild(g);d(e,g)}else{for(var j=0;j<c.length;j++){g=f.createElement(ab);g.language=bb;g.text=c[j];e.appendChild(g);d(e,g)}}}
fri.onScriptDownloaded=function(a){m(function(){n(a)})};s(cb,db);var o=q.createElement(ab);o.src=l;q.getElementsByTagName(eb)[0].appendChild(o)}
fri.__startLoadingFragment=function(a){return D(a)};fri.__installRunAsyncCode=function(a){var b=y();var c=x().createElement(ab);c.language=bb;c.text=a;b.appendChild(c);b.removeChild(c)};function B(){var c={};var d;var e;var f=q.getElementsByTagName(fb);for(var g=0,h=f.length;g<h;++g){var j=f[g],k=j.getAttribute(gb),l;if(k){k=k.replace(hb,V);if(k.indexOf(ib)>=0){continue}if(k==jb){l=j.getAttribute(kb);if(l){var m,n=l.indexOf(lb);if(n>=0){k=l.substring(0,n);m=l.substring(n+1)}else{k=l;m=V}c[k]=m}}else if(k==mb){l=j.getAttribute(kb);if(l){try{d=eval(l)}catch(a){alert(nb+l+ob)}}}else if(k==pb){l=j.getAttribute(kb);if(l){try{e=eval(l)}catch(a){alert(nb+l+qb)}}}}}u=function(a){var b=c[a];return b==null?null:b};__propertyErrorFunction=d;fri.__errFn=e}
function C(){function e(a){var b=a.lastIndexOf(rb);if(b==-1){b=a.length}var c=a.indexOf(sb);if(c==-1){c=a.length}var d=a.lastIndexOf(tb,Math.min(c,b));return d>=0?a.substring(0,d+1):V}
function f(a){if(a.match(/^\w+:\/\//)){}else{var b=q.createElement(ub);b.src=a+vb;a=e(b.src)}return a}
function g(){var a=u(wb);if(a!=null){return a}return V}
function h(){var a=q.getElementsByTagName(ab);for(var b=0;b<a.length;++b){if(a[b].src.indexOf(xb)!=-1){return e(a[b].src)}}return V}
function j(){var a=q.getElementsByTagName(yb);if(a.length>0){return a[a.length-1].href}return V}
function k(){var a=q.location;return a.href==a.protocol+zb+a.host+a.pathname+a.search+a.hash}
var l=g();if(l==V){l=h()}if(l==V){l=j()}if(l==V&&k()){l=e(q.location.href)}l=f(l);return l}
function D(a){if(a.match(/^\//)){return a}if(a.match(/^[a-zA-Z]+:\/\//)){return a}return fri.__moduleBase+a}
function E(){var g=[];var h;function j(a,b){var c=g;for(var d=0,e=a.length-1;d<e;++d){c=c[a[d]]||(c[a[d]]=[])}c[a[e]]=b}
var k=[];var l=[];function m(a){var b=l[a](),c=k[a];if(b in c){return b}var d=[];for(var e in c){d[c[e]]=e}if(__propertyErrorFunc){__propertyErrorFunc(a,d,b)}throw null}
l[Ab]=function(){var a;if(a==null){var b=new RegExp(Bb);var c=b.exec(location.search);if(c!=null){a=c[1]}}if(a==null){a=u(Ab)}if(!t(Ab,a)){var d=[Cb,Db,Eb,Fb,Gb,Hb,Ib];var e=null;var f=false;for(i in d){f|=a==d[i];if(t(Ab,d[i])){e=d[i]}if(i==d.length-1||f&&e!=null){a=e;break}}}return a};k[Ab]={DEBUG:0,INFO:1};l[Jb]=function(){return /(android|iphone|ipod|ipad)/i.test(window.navigator.userAgent)?Kb:Lb};k[Jb]={mobilesafari:0,not_mobile:1};l[Mb]=function(){var b=navigator.userAgent.toLowerCase();var c=function(a){return parseInt(a[1])*1000+parseInt(a[2])};if(function(){return b.indexOf(Nb)!=-1}())return Nb;if(function(){return b.indexOf(Ob)!=-1}())return Pb;if(function(){return b.indexOf(Qb)!=-1&&q.documentMode>=9}())return Rb;if(function(){return b.indexOf(Qb)!=-1&&q.documentMode>=8}())return Sb;if(function(){var a=/msie ([0-9]+)\.([0-9]+)/.exec(b);if(a&&a.length==3)return c(a)>=6000}())return Tb;if(function(){return b.indexOf(Ub)!=-1}())return Vb;return Wb};k[Mb]={gecko1_8:0,ie6:1,ie8:2,ie9:3,opera:4,safari:5};t=function(a,b){return b in k[a]};fri.__getPropMap=function(){var a={};for(var b in k){if(k.hasOwnProperty(b)){a[b]=m(b)}}return a};fri.__computePropValue=m;p.__gwt_activeModules[L].bindings=fri.__getPropMap;s(H,Xb);if(r()){return D(Yb)}var n;try{j([Db,Kb,Pb],Zb);j([Db,Lb,Rb],$b);j([Eb,Lb,Vb],_b);j([Db,Lb,Vb],ac);j([Eb,Lb,Pb],bc);j([Eb,Kb,Pb],cc);j([Db,Lb,Pb],dc);j([Eb,Lb,Rb],ec);n=g[m(Ab)][m(Jb)][m(Mb)];var o=n.indexOf(fc);if(o!=-1){h=parseInt(n.substring(o+1),10);n=n.substring(0,o)}}catch(a){}fri.__softPermutationId=h;return D(n+gc)}
function F(){if(!p.__gwt_stylesLoaded){p.__gwt_stylesLoaded={}}function c(a){if(!__gwt_stylesLoaded[a]){var b=q.createElement(hc);b.setAttribute(ic,jc);b.setAttribute(kc,D(a));q.getElementsByTagName(eb)[0].appendChild(b);__gwt_stylesLoaded[a]=true}}
s(lc,I);c(mc);s(lc,nc)}
B();fri.__moduleBase=C();v[L].moduleBase=fri.__moduleBase;var G=E();F();s(H,nc);A(G);return true}
fri.succeeded=fri();
>>>>>>> Stashed changes
