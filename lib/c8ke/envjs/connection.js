/* Stores of connections */
Envjs.connections = [];

Envjs.connections.addConnection = function(xhr){
  log.debug('registering connection.');
  Envjs.connections.push(xhr);
};

Envjs.connections.removeConnection = function(xhr){
  log.debug('unregistering connection.');
  var i;
  for(i = 0; i < Envjs.connections.length; i++){
    if(Envjs.connections[i] === xhr){
      Envjs.connections.splice(i,1);
      break;
    }
  }
};


Envjs.localXHR = function(url, xhr, connection, data){
  try{
    // make the fake file level request
    if ( "PUT" == xhr.method.toUpperCase() || "POST" == xhr.method.toUpperCase() ) {
      log.debug('writing to file %s', url);
      data =  data || "" ;
      Envjs.writeToFile(data, url);
    } else if ( xhr.method == "DELETE" ) {  
      log.debug('not deleting file %s, because delete file not implemented yet', url);
      // Envjs.deleteFile(url);
    } else {
      log.debug('reading from file %s', url);
      xhr.responseText = Envjs.readFromFile(url);
    }
    
    // process the response
    try {
      xhr.readyState = 4;
      xhr.status = 200;
      xhr.statusText = "";
      
      if(url.match(/html$/)){
          xhr.responseHeaders["Content-Type"] = 'text/html';
      }else if(url.match(/.xml$/)){
          xhr.responseHeaders["Content-Type"] = 'text/xml';
      }else if(url.match(/.js$/)){
          xhr.responseHeaders["Content-Type"] = 'text/javascript';
      }else if(url.match(/.json$/)){
          xhr.responseHeaders["Content-Type"] = 'application/json';
      }else{
          xhr.responseHeaders["Content-Type"] = 'text/plain';
      }
      //xhr.responseHeaders['Last-Modified'] = connection.getLastModified();
      //xhr.responseHeaders['Content-Length'] = headerValue+'';
      //xhr.responseHeaders['Date'] = new Date()+'';
      
    } catch(ee) {
      
      log.error('failed to load response headers', ee);
    }
  } catch(e) {
    
    log.error('failed to open file %s %s', url, e);
    connection = null;
    xhr.readyState = 4;
    xhr.statusText = "Local File Protocol Error";
    xhr.responseText = "<html><head/><body><p>"+ e+ "</p></body></html>";
  }
};


/*
  requires Document, XMLSerializer (in dom.js)
*/

/**
 * establishes connection and calls responsehandler
 * @param {Object} xhr
 * @param {Object} responseHandler
 * @param {Object} data
 */
Envjs.connection = function(xhr, responseHandler, data) {
  var url = xhr.url;
  
  if (/^file\:/.test(url)) {
    log.debug('establishing file connection');
    Envjs.localXHR(url, xhr, connection, data);
  } else {
    
    // repackage data
    if (data instanceof Document) {
      data = (new XMLSerializer()).serializeToString(data);
    } else if ( !data.length || data.length == 0) {
      data = null;
    }
    
    // making the request
    var requester = RestClient[xhr.method.toLowerCase()]; 
    var response;
    try {
      if ( data ) {
        response = requester(url, data);
      } else {
        response = requester(url);
      }
    } catch(e) {
      log.error('could not connect to url: %s\n%s', url, e);
    }
    
    // process the response
    var headers = response.raw_headers;
    try {
      for (var header in headers ) {
        log.debug('response header [%s] = %s', header, headers[header]);
        xhr.responseHeaders[header] = headers[header];
      }
    } catch(e) {
      log.error('failed to load response headers \n%s', e);
    }
    xhr.readyState = 4;
    xhr.status = response.code();
    xhr.statusText = response.description() || "";
    log.debug('%s %s %s %s', xhr.method, xhr.status, xhr.url, xhr.statusText);
    xhr.responseText = response.body() + '';
  }

  if (responseHandler) {
    log.debug('calling ajax response handler');
    if (!xhr.async) {
      log.debug('calling sync response handler directly');
      responseHandler();
    } else {
      log.debug('using setTimeout for async response handler');
      setTimeout(responseHandler, 1);
    }
  }
};
