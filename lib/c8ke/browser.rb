module C8ke
  class Browser
    attr_accessor :runtime
    
    def initialize
      self.runtime = Runtime.new
      runtime.load( envjs_path )
    end
    
    def envjs_path
      File.dirname(__FILE__) + "/../vendor/envjs/rubyracer.js"
    end
  end
end