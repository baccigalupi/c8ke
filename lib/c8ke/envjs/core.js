var Envjs = {
  os_name :       Ruby.CONFIG.host_os,
  os_arch :       Ruby.CONFIG.host_cpu,
  homedir :       Ruby.ENV.HOME,
  tempdir :       Ruby.ENV.TMPDIR,
  lang :          Ruby.ENV.LANG,
  revision :      Ruby.ENV.RUBY_VERSION,
  platform :      "V8 RubyRacer",
  javaEnabled :   false
};

Envjs.exit    = function(){};
Envjs.log     = function( message ){ print( message ); };
