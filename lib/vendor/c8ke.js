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