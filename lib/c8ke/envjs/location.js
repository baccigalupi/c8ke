/*
* Envjs xhr.1.3.pre03 
* Pure JavaScript Browser Environment
* By John Resig <http://ejohn.org/> and the Envjs Team
* Copyright 2008-2010 John Resig, under the MIT License
*/

/*
* Envjs xhr.1.3.pre03 
* Pure JavaScript Browser Environment
* By John Resig <http://ejohn.org/> and the Envjs Team
* Copyright 2008-2010 John Resig, under the MIT License
* 
* Parts of the implementation originally written by Yehuda Katz.
* 
* This file simply provides the global definitions we need to 
* be able to correctly implement to core browser (XML)HTTPRequest 
* interfaces.

This module leaks the following global definitions. 

var Location
*/


/**
* These functions require network IO provided by XMLHttpRequest
*/
(function() {

    Envjs.extend(Document.prototype, {
        load: function(url) {
            if (this.documentURI == 'about:html') {
                this.location.assign(url);
            } else if (this.documentURI == url) {
                this.location.reload(false);
            } else {
                this.location.replace(url);
            }
        },
        get location() {
            return this.ownerWindow.location;
        },
        set location(url) {
            //very important or you will go into an infinite
            //loop when creating a xml document
            this.ownerWindow.location = url;
        }
    });

} (
/*Document/Location Mixin*/
));
/**
* Location
*
* Mozilla MDC:
* https://developer.mozilla.org/En/DOM/Window.location
* https://developer.mozilla.org/en/DOM/document.location
*
* HTML5: 6.10.4 The Location interface
* http://dev.w3.org/html5/spec/Overview.html#location
*
* HTML5: 2.5.3 Interfaces for URL manipulation
* http://dev.w3.org/html5/spec/Overview.html#url-decomposition-idl-attributes
* All of section 2.5 is worth reading, but 2.5.3 contains very
* detailed information on how getters/setter should work
*
* NOT IMPLEMENTED:
*  HTML5: Section 6.10.4.1 Security -- prevents scripts from another domain
*   from accessing most of the 'Location'
*  Not sure if anyone implements this in HTML4
*/
(function() {

    exports.Location = Location = function(url, doc, history) {
        log = log || Envjs.logger('Envjs.Location');
        log.debug('Location url %s', url);
        var $url = url,
        $document = doc ? doc: null,
        $history = history ? history: null;

        var parts = Envjs.urlparse.urlsplit($url);

        return {
            get hash() {
                return parts.fragment ? '#' + parts.fragment: parts.fragment;
            },
            set hash(s) {
                if (s[0] === '#') {
                    parts.fragment = s.substr(1);
                } else {
                    parts.fragment = s;
                }
                $url = Envjs.urlparse.urlunsplit(parts);
                if ($history) {
                    $history.add($url, 'hash');
                }
            },

            get host() {
                return parts.netloc;
            },
            set host(s) {
                if (!s || s === '') {
                    return;
                }

                parts.netloc = s;
                $url = Envjs.urlparse.urlunsplit(parts);

                // this regenerates hostname & port
                parts = Envjs.urlparse.urlsplit($url);

                if ($history) {
                    $history.add($url, 'host');
                }
                this.assign($url);
            },

            get hostname() {
                return parts.hostname;
            },
            set hostname(s) {
                if (!s || s === '') {
                    return;
                }

                parts.netloc = s;
                if (parts.port != '') {
                    parts.netloc += ':' + parts.port;
                }
                parts.hostname = s;
                $url = Envjs.urlparse.urlunsplit(parts);
                if ($history) {
                    $history.add($url, 'hostname');
                }
                this.assign($url);
            },

            get href() {
                return $url;
            },
            set href(url) {
                $url = url;
                if ($history) {
                    $history.add($url, 'href');
                }
                this.assign($url);
            },

            get pathname() {
                return parts.path;
            },
            set pathname(s) {
                if (s[0] === '/') {
                    parts.path = s;
                } else {
                    parts.path = '/' + s;
                }
                $url = Envjs.urlparse.urlunsplit(parts);

                if ($history) {
                    $history.add($url, 'pathname');
                }
                this.assign($url);
            },

            get port() {
                // make sure it's a string
                return '' + parts.port;
            },
            set port(p) {
                // make a string
                var s = '' + p;
                parts.port = s;
                parts.netloc = parts.hostname + ':' + parts.port;
                $url = Envjs.urlparse.urlunsplit(parts);
                if ($history) {
                    $history.add($url, 'port');
                }
                this.assign($url);
            },

            get protocol() {
                return parts.scheme + ':';
            },
            set protocol(s) {
                var i = s.indexOf(':');
                if (i != -1) {
                    s = s.substr(0, i);
                }
                parts.scheme = s;
                $url = Envjs.urlparse.urlunsplit(parts);
                if ($history) {
                    $history.add($url, 'protocol');
                }
                this.assign($url);
            },

            get search() {
                return (parts.query) ? '?' + parts.query: parts.query;
            },
            set search(s) {
                if (s[0] == '?') {
                    s = s.substr(1);
                }
                parts.query = s;
                $url = Envjs.urlparse.urlunsplit(parts);
                if ($history) {
                    $history.add($url, 'search');
                }
                this.assign($url);
            },

            toString: function() {
                return $url;
            },

            assign: function(url,
            /*non-standard*/
            method, data) {
                var _this = this,
                xhr,
                event;
                method = method || "GET";
                data = data || null;
                log.debug('assigning %s', url);

                //we can only assign if this Location is associated with a document
                if ($document) {
                    log.debug('fetching %s (async? %s)', url, $document.async);
                    xhr = new XMLHttpRequest();

                    xhr.setRequestHeader('Referer', $document.location);
                    log.debug("REFERER: %s", $document.location);
                    // TODO: make async flag a Envjs paramter
                    xhr.open(method, url, false);
                    //$document.async);
                    // TODO: is there a better way to test if a node is an HTMLDocument?
                    if ($document.toString() === '[object HTMLDocument]') {
                        //tell the xhr to not parse the document as XML
                        log.debug('loading html document');
                        xhr.onreadystatechange = function() {
                            log.debug('readyState %s', xhr.readyState);
                            if (xhr.readyState === 4) {
                                switch (xhr.status) {
                                case 301:
                                case 302:
                                case 303:
                                case 305:
                                case 307:
                                    log.debug('status is not good for assignment %s', xhr.status);
                                    break;
                                default:
                                    log.debug('status is good for assignment %s', xhr.status);
                                    $url = xhr.url;
                                    parts = Envjs.urlparse.urlsplit($url);
                                    log.debug('new document location %s', xhr.url);
                                    Envjs.exchangeHTMLDocument($document, xhr.responseText, xhr.url);
                                }
                            }
                        };
                        try {
                            xhr.send(data, false);
                            //dont parse html
                        } catch(e) {
                            log.debug('failed to load content %s', e);
                            Envjs.exchangeHTMLDocument(
                            $document,
                            "<html><head><title>Error Loading</title></head><body>" + e + "</body></html>",
                            xhr.url
                            );
                        }
                    } else {
                        //Treat as an XMLDocument
                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === 4) {
                                log.debug('exchanging xml content %s', e);
                                $document = xhr.responseXML;
                                $document.baseURI = xhr.url;
                                if ($document.createEvent) {
                                    event = $document.createEvent('Event');
                                    event.initEvent('DOMContentLoaded');
                                    $document.dispatchEvent(event, false);
                                }
                            }
                        };
                        xhr.send();
                    }
                }
                //end if($document)
            },
            reload: function(forceget) {
                //for now we have no caching so just proxy to assign
                log.debug('reloading %s', $url);
                this.assign($url);
            },
            replace: function(url,
            /*non-standard*/
            method, data) {
                this.assign(url, method, data);
            }
        };
    };

} (/*Location*/));
