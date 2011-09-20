var exports = {};

var Envjs = function(){
  var self = this;
  var i;
  var override = function(){
    for(i=0; i<arguments.length; i++){
      Envjs.extend( self, arguments[i] );
    }
  };
   
  if(arguments.length === 1 && typeof(arguments[0]) == 'string'){
    window.location = arguments[0];
  } else if (arguments.length === 1 && typeof(arguments[0]) == "object"){
    override(arguments[0]);
  } else if(arguments.length === 2 && typeof(arguments[0]) == 'string'){
    override(arguments[1]);
    window.location = arguments[0];
  }
  return;
};


require('helpers');
exports.Helpers.extend(Envjs, exports.Helpers);


// System attributes, overwriteable 

Envjs.os_name =       Ruby.CONFIG.host_os;
Envjs.os_arch =       Ruby.CONFIG.host_cpu;
Envjs.homedir =       Ruby.ENV.HOME;
Envjs.tempdir =       Ruby.ENV.TMPDIR;
Envjs.lang =          Ruby.ENV.LANG;
Envjs.revision =      Ruby.ENV.RUBY_VERSION;
Envjs.platform =      "V8 RubyRacer";
Envjs.javaEnabled =   false;

// System functions

Envjs.exit    = function(){};
Envjs.sync = function() { console.log("c8ke js is threadless. Syncing is not possible!"); };
Envjs.spawn = function(fn) { fn.call(); };
Envjs.sleep = function(amount) { Ruby.sleep( amount/1000.0 ) }
Envjs._guid = 0;  
Envjs.guid = function(){ return ++Envjs._guid; };


// Console and Logging 
require('console');
var console = exports.console;
require('logging');

// File managment
require('file');

// Building contexts inside the browser, with separate eval system and scope
// requires help from ruby racer to build a separate context
// /**
//  * Makes an object window-like by proxying object accessors
//  * @param {Object} scope
//  * @param {Object} parent
//  */
// Envjs.proxy = function(scope, parent) {
//   try{
//     if(scope == World){
//       return scope;
//     }else{
//       return new_context();
//     }
//   }catch(e){
//     console.log('failed to init standard objects %s %s \n%s', scope, parent, e);
//   }
// };


