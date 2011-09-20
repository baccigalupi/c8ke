exports.Helpers = {
  /**
   * @author john resig
   */
  // Helper method for extending one object with another.
  extend : function(a,b) {
    for ( var i in b ) {
      if( b.hasOwnProperty(i) ){
        var g = b.__lookupGetter__(i), s = b.__lookupSetter__(i);
        if ( g || s ) {
          if ( g ) { a.__defineGetter__(i, g); }
          if ( s ) { a.__defineSetter__(i, s); }
        } else {
          a[i] = b[i];
        }
      }
    } 
    return a;
  },

  /**
   * @author ariel flesler
   *    http://flesler.blogspot.com/2008/11/fast-trim-function-for-javascript.html
   * @param {Object} str
   */
  trim : function( str ){
    return (str || "").replace( /^\s+|\s+$/g, "" );
  },
  
  eval : function( context, source, name ) {
    if( context == __this__ ){
      return __this__.eval( source );
    } else {
      log.debug('evaluating in proxy scope %s', context );
      return context.eval( source );
    }
  }
};

require('aspect');
Envjs.Aspect = exports.Aspect;
