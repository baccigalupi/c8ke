Bundler.require
require 'v8' # TODO: change the bundler declaration to include as this library

c8ke_dir = File.dirname(__FILE__) + '/c8ke'
require c8ke_dir + "/browser"