!function(e){var t={};function n(r){if(t[r])return t[r].exports;var o=t[r]={i:r,l:!1,exports:{}};return e[r].call(o.exports,o,o.exports,n),o.l=!0,o.exports}n.m=e,n.c=t,n.d=function(e,t,r){n.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:r})},n.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},n.t=function(e,t){if(1&t&&(e=n(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var r=Object.create(null);if(n.r(r),Object.defineProperty(r,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var o in e)n.d(r,o,function(t){return e[t]}.bind(null,o));return r},n.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return n.d(t,"a",t),t},n.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},n.p="",n(n.s=2)}([,,function(e,t,n){n(3),e.exports=n(4)},function(e,t,n){"use strict";window.__firefox__||Object.defineProperty(window,"__firefox__",{enumerable:!1,configurable:!1,writable:!1,value:{userScripts:{},includeOnce:function(e,t){return!!__firefox__.userScripts[e]||(__firefox__.userScripts[e]=!0,"function"==typeof t&&t(),!1)}}})},function(e,t,n){"use strict";n(5)},function(e,t,n){"use strict";webkit.messageHandlers.trackingProtectionStats&&function(){var e=!0;Object.defineProperty(window.__firefox__,"TrackingProtectionStats",{enumerable:!1,configurable:!1,writable:!1,value:{}}),Object.defineProperty(window.__firefox__.TrackingProtectionStats,"setEnabled",{enumerable:!1,configurable:!1,writable:!1,value:function(t,n){n===SECURITY_TOKEN&&t!==e&&(e=t,f(t))}});var t=new Array,n=null;function r(r){if(e){try{if(document.location.host===new URL(r).host)return}catch(e){}r&&t.push(r),n||(n=setTimeout(function(){n=null,t.length<1||(webkit.messageHandlers.trackingProtectionStats.postMessage({urls:t}),t=new Array)},200))}}function o(){[].slice.apply(document.scripts).forEach(function(e){r(e.src)}),[].slice.apply(document.images).forEach(function(e){r(e.src)}),[].slice.apply(document.getElementsByTagName("iframe")).forEach(function(e){r(e.src)})}var i=null,c=null,u=null,s=null,a=null;function f(e){if(!e)return window.removeEventListener("load",o,!1),void(i&&(XMLHttpRequest.prototype.open=i,XMLHttpRequest.prototype.send=c,window.fetch=u,a.disconnect(),i=c=s=a=null));if(!i){window.addEventListener("load",o,!1),i||(i=XMLHttpRequest.prototype.open,c=XMLHttpRequest.prototype.send);var t=new WeakMap;new WeakMap,XMLHttpRequest.prototype.open=function(e,n){return t.set(this,n),i.apply(this,arguments)},XMLHttpRequest.prototype.send=function(e){return r(t.get(this)),c.apply(this,arguments)},u||(u=window.fetch),window.fetch=function(e,t){return"string"==typeof e?r(e):e instanceof Request&&r(e.url),u.apply(window,arguments)},s||(s=Object.getOwnPropertyDescriptor(Image.prototype,"src")),delete Image.prototype.src,Object.defineProperty(Image.prototype,"src",{get:function(){return s.get.call(this)},set:function(e){r(this.src),s.set.call(this,e)}}),(a=new MutationObserver(function(e){e.forEach(function(e){e.addedNodes.forEach(function(e){if("SCRIPT"===e.tagName&&e.src)r(e.src);else if("IMG"===e.tagName&&e.src)r(e.src);else if("IFRAME"===e.tagName&&e.src){if("about:blank"===e.src)return;r(e.src)}else"LINK"===e.tagName&&e.href&&r(e.href)})})})).observe(document.documentElement,{childList:!0,subtree:!0})}}f(!0)}()}]);