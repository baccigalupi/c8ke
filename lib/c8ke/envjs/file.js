/**
 * Get 'Current Working Directory'
 */
Envjs.getcwd = function() { return Ruby.ENV.PWD; };

/**
 * Used to read the contents of a local file
 * @param {Object} url
 */
Envjs.readFromFile = function( url ){
  if( /^file\:\/\//.test( url ) ) {
    url = url.substring(7,url.length);
    return File.read(url);
  } 
};

Envjs.writeToFile = function(text, url){
  return File.write({
    url : url,
    text : text
  });
};