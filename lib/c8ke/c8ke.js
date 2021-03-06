var __this__ = this;

var Paths = {
  available : Ruby.paths,
  add : Ruby.add_path
}

var File = {
  at : function( path ) {
    if( !path.match(/\.[a-z]+$/) ) {
      path += ".js";
    }
    
    if( this.exist( path ) ) {
      return this.get( path )
    };
  
    for( var i = 0; i < Paths.available.length; i++ ){
      var new_path =  Paths.available[i] + '/' + path;
      if( this.exist( new_path ) ) {
        return this.get( new_path );
      }
    }
    return false;
  },

  get : function( path ) {
    return Ruby.File.new( path, 'r');
  },

  exist : function( path ) {
    return Ruby.File['exist?'](path);
  },
  
  read : function( path ) {
    log.debug('reading from ' + path);
    return this.get(path).read();
  },
  
  write : function( options ) {
    log.debug('writing "' + options.text + '" to ' + options.url);
    Ruby.write_to_file(options);
  },
  
  cache : {}
};

var require = (function() {
  function cache(file) {
    var path = file.path;
    if ( !File.cache[path] ){
      var source = file.read();
      File.cache[path] = source;
    }
    return File.cache[path]; 
  };
 
  function require(path) {
    var file = File.at(path);
    
    if ( file ) {
      var original_length = Paths.available.length;
      Paths.add(file.path);
      __this__.eval( cache( file ) );
      if (Paths.available.length > original_length) {
        Paths.available.shift();
      }
    }
    else {
      Ruby.raise("Cannot find required file: " + path);
    }
  };  
  
  return require;
})();

require('envjs/core');
