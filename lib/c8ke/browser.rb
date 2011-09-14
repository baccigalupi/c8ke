module C8ke
  class Browser < V8::Context
    include Config
    Config = CONFIG
    Env = ENV
    
    def initialize
      super
      configure
      load( File.expand_path(File.dirname(__FILE__))  + '/c8ke.js' )
    end
    
    def configure
      self['print'] = lambda { |message| puts message }
      ruby = { 
        'gc' => lambda{ GC.start },
        'puts' => Kernel.method(:puts),
        'warn' => Kernel.method(:warn),
        'caller' => Kernel.method(:caller),
        'rand' => Kernel.method(:rand),
        'sleep' => Kernel.method(:sleep),
        'command_line' => lambda { |command| `#{command}` },
        'raise' => lambda { |message| raise( message ) },
        'version' => RUBY_DESCRIPTION,
        'File' => File,
        'add_path' => lambda{ |path| add_path(path) }
      }
      self['Ruby'] = ruby
      
      self['Ruby']['CONFIG'] = {}
      CONFIG.each do |key, value|
        self['Ruby']['CONFIG'][key] = value
      end
      
      self['Ruby']['ENV'] = {}
      ENV.each do |key, value|
        self['Ruby']['ENV'][key] = value
      end
    end
    
    def paths
      @paths ||= []
    end
    
    def add_path( file_path )
      new_path = file_path.match(/\.[a-z]+$/i) ? File.dirname( file_path ) : file_path
      paths.unshift(new_path) unless paths.include?(new_path)
      if self['Paths']
        self['Paths']['available'] = paths
      else
        self["Ruby"]['paths'] = paths
      end
    end
    
    def load( file_path )
      add_path( file_path )
      super
    end
    
    def to_s
      "<#{self.class} ##{object_id}>"
    end
  end
end
