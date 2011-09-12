Paths.add = Ruby.add_path;
var Env = this;

var File = {
  at : function( path ) {
    if( this.exist( path ) ) {
      return this.get( path )
    };
  
    for( var i = 0; i < Paths.length; i++ ){
      var new_path =  Paths[i] + '/' + path;
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
  }
};

var require = (function() {
  var cached = {};
  
  function cache(file) {
    var path;
    if ( !cached[path] ){
      var source = file.read();
      cached[path] = source;
    }
    return cached[path]; 
  };
  
  //     source = "(function (require, exports, module) { "+source+"\n});";
  //     cached[id] = {
  //         exports: {},
  //         module: {
  //             id: id,
  //             uri: id
  //         }
  //     };
  // changing path to include file's path
  //     var previousPath = currentPath;
  //     try {
  //         currentPath = id.substr(0, id.lastIndexOf('/')) || '.';
  //         var func = __this__.eval(source);
  //         func(require, cached[id].exports, cached[id].module);
  //     } finally {
  //         currentPath = previousPath;
  //     }
  // }
  
  function require(path) {
    var file = File.at(path);
    if ( file ) {
      Env.eval( cache(file) );
    } else {
      Ruby.raise("Cannot find required file: " + path);
    }
  };  
  
  return require;
})();

