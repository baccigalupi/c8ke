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
  },
  
  /**
   * resolves location relative to doc location
   *
   * @param {Object} path  Relative or absolute URL
   * @param {Object} base  (semi-optional)  The base url used in resolving "path" above
   */
  uri : function(path, base) {
    //console.log('constructing uri from path %s and base %s', path, base);
    path = path+'';
    // Semi-common trick is to make an iframe with src='javascript:false'
    //  (or some equivalent).  By returning '', the load is skipped'
    var js = 'javascript';
    if (path.indexOf(js+':') === 0) {
      return '';
    }

    // if path is absolute, then just normalize and return
    if (path.match('^[a-zA-Z]+://')) {
      return Envjs.urlparse.urlnormalize(path);
    }

    // interesting special case, a few very large websites use
    // '//foo/bar/' to mean 'http://foo/bar'
    if (path.match('^//')) {
      path = 'http:' + path;
    }

    // if base not passed in, try to get it from document
    // Ideally I would like the caller to pass in document.baseURI to
    //  make this more self-sufficient and testable
    if (!base && document) {
      base = document.baseURI;
    }

    // about:blank doesn't count
    if (base === 'about:blank'){
      base = '';
    }

    // if base is still empty, then we are in QA mode loading local
    // files.  Get current working directory
    if (!base) {
      base = 'file://' +  Envjs.getcwd() + '/';
    }
    // handles all cases if path is abosulte or relative to base
    // 3rd arg is "false" --> remove fragments
    var newurl = Envjs.urlparse.urlnormalize(Envjs.urlparse.urljoin(base, path, false));
    //console.log('uri %s %s = %s', base, path, newurl);
    return newurl;
  }
};

require('aspect');
Envjs.Aspect = exports.Aspect;
require('urlparse');
