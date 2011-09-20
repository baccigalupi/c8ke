Envjs.log         = function( message ){ print( message ); };
Envjs.lineSource  = function(e){ return "(line ?)"; };
Envjs.CURSOR      = "envjs>";
Envjs.prompt      = function(){
  Ruby.$stdout.write( Envjs.CURSOR + ' ' );
  Ruby.$stdout.flush;
};
Envjs.trace       = function(){};

/**
 * Starts a read-eval-print-loop
 */
Envjs.repl = function() {
  var line, waiting;
  var $_ = null;
  var log = Envjs.logger('Envjs.Core.REPL');
  Envjs.on('tick', function() {
    log.debug('tick for REPL');
    if (!waiting) {
      log.debug('not waiting in REPL');
      waiting = true;
      Envjs.prompt();
      log.debug('waiting for line in');
      Envjs.spawn(function() {
        log.info('async waiting for line in');
        line = Envjs.readConsole();
        if (line === "quit" || line === "exit") {
          log.info('%sting', line);
          Envjs.emit('exit', 'repl');
        } else {
          setTimeout(function() {
            try {
              if (line) {
                log.info('evaluating console line in: %s', line);
                $_ = Envjs['eval'](__this__, line);
                if ($_ !== undefined) {
                  log.info('result of evaluation: %s', $_);
                  Envjs.log($_);
                }
              } else {
                log.info('not evaluating console line in: %s', line);
              }
            } catch(e) {
              Envjs.log('[Envjs.REPL Error] ' + e);
            } finally {
              waiting = false;
            }
          },1);
        }
      });
    } else {
      log.debug('waiting in REPL');
    }
  });
};

/**
 * @author envjs team
 * @Console
 *
 * Envjs console.1.3.pre03 
 * Pure JavaScript Browser Environment
 * By John Resig <http://ejohn.org/> and the Envjs Team
 * Copyright 2008-2010 John Resig, under the MIT License
 */

//CLOSURE_START
( function(){

  /**
  * @author envjs team
  * borrowed 99%-ish with love from firebug-lite
  */

  function escapeHTML(value) { return value; }
    
  function objectToString(object) {
    try { return object+""; }
    catch (exc) { return null;}
  }
  
  // ********************************************************************************************
  
  function appendText(object, html) {
    html.push(escapeHTML(objectToString(object)));
  }
  
  function appendNull(object, html) {
    html.push(escapeHTML(objectToString(object)));
  }
  
  function appendString(object, html) {
    html.push(escapeHTML(objectToString(object)));
  }
  
  function appendInteger(object, html) {
    html.push(escapeHTML(objectToString(object)));
  }
  
  function appendFloat(object, html) {
    html.push(escapeHTML(objectToString(object)));
  }
  
  function appendFunction(object, html) {
    var reName = /function ?(.*?)\(/;
    var m = reName.exec(objectToString(object));
    var name = m ? m[1] : "function";
    html.push(escapeHTML(name));
  }

  function appendObjectFormatted(object, html) {
    var text = objectToString(object);
    var reObject = /\[object (.*?)\]/;
  
    var m = reObject.exec(text);
    html.push( m ? m[1] : text);
  }
  
  function appendSelector(object, html) {
    html.push(escapeHTML(object.nodeName.toLowerCase()));
    if (object.id) {
        html.push(escapeHTML(object.id));
    }
    if (object.className) {
        html.push(escapeHTML(object.className));
    }
  }

  function appendNode(node, html){
    if (node.nodeType == 1) {
      html.push( node.nodeName.toLowerCase());
  
      for (var i = 0; i < node.attributes.length; ++i) {
        var attr = node.attributes[i];
        if (!attr.specified) { continue; }
        html.push( attr.nodeName.toLowerCase(),escapeHTML(attr.nodeValue));
      }
  
      if (node.firstChild) {
        for (var child = node.firstChild; child; child = child.nextSibling) {
          appendNode(child, html);
        }
  
        html.push( node.nodeName.toLowerCase());
      }
    }
    else if (node.nodeType === 3) {
      html.push(escapeHTML(node.nodeValue));
    }
  }
  
  function appendObject(object, html) {
    try {
      if (object === undefined) {
        appendNull("undefined", html);
      } else if (object === null) {
        appendNull("null", html);
      } else if (typeof object == "string") {
        appendString(object, html);
      } else if (typeof object == "number") {
        appendInteger(object, html);
      } else if (typeof object == "function") {
        appendFunction(object, html);
      } else if (object.nodeType == 1) {
        appendSelector(object, html);
      } else if (typeof object == "object") {
        appendObjectFormatted(object, html);
      } else {
        appendText(object, html);
      }
    }
    catch (exc) {}
  }

  function parseFormat(format) {
    var parts = [];
  
    var reg = /((^%|[^\\]%)(\d+)?(\.)([a-zA-Z]))|((^%|[^\\]%)([a-zA-Z]))/;
    var appenderMap = {s: appendText, d: appendInteger, i: appendInteger, f: appendFloat};
  
    for (var m = reg.exec(format); m; m = reg.exec(format)) {
      var type = m[8] ? m[8] : m[5];
      var appender = type in appenderMap ? appenderMap[type] : appendObject;
      var precision = m[3] ? parseInt(m[3], 10) : (m[4] == "." ? -1 : 0);
  
      parts.push(format.substr(0, m[0][0] == "%" ? m.index : m.index+1));
      parts.push({appender: appender, precision: precision});
  
      format = format.substr(m.index+m[0].length);
    }
  
    parts.push(format);
  
    return parts;
  }

  function logFormatted(objects, className) {
    var html = [],
      i= 0,
      object;
  
    var format = objects[0];
    var objIndex = 0;
  
    if (typeof(format) != "string") {
      format = "";
      objIndex = -1;
    }
  
    var parts = parseFormat(format);
    for (i = 0; i < parts.length; ++i)
    {
      var part = parts[i];
      if (part && typeof(part) == "object")
      {
        object = objects[++objIndex];
        part.appender(object, html);
      }
      else {
        appendText(part, html);
      }
    }
  
    for (i = objIndex+1; i < objects.length; ++i) {
      appendText(" ", html);
  
      object = objects[i];
      if (typeof(object) == "string") {
        appendText(object, html);
      } else {
        appendObject(object, html);
      }
    }
  
    Envjs.log(html.join(' '));
  }

  Console = function(module){
    var $level,
        $logger,
        $null = function(){};

    $logger = {
      log: function(level)   { logFormatted(arguments, "");},
      debug: function(level) { logFormatted(arguments, "DEBUG");},
      info:  function(level) { logFormatted(arguments, "INFO");},
      warn:  function(level) { logFormatted(arguments, "WARN");},
      error:  function(level){ logFormatted(arguments, "ERROR");},
      trace: function(){ Envjs.trace(); }
    };

    return $logger;
  };

  exports.console = new Console();
  
  /**
   * @author john resig & the envjs team
   * @uri http://www.envjs.com/
   * @copyright 2008-2010
   * @license MIT
   */
  //CLOSURE_END
}());
