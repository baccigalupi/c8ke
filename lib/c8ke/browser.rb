module C8ke
  class Browser < V8::Context
    include Config
    
    def initialize
      super
      configure_ruby
      configure_envjs
      load(c8ke_path)
      # load( racer_path ) 
    end
    
    def c8ke_path
      vendor_path + "/c8ke.js"
    end
    
    def vendor_path
      File.expand_path(File.dirname(__FILE__) + "/../vendor")
    end
    
    def configure_ruby
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
        'File' => File
      }
      self['Ruby'] = ruby
      self['print'] = lambda { |message| puts message }
      
    end

    def configure_envjs
      # self['__this__']  = self
      #  self['sync']      = lambda{|fn| Proc.new{|*args| fn.call(*args) }}
      #  self['spawn']     = lambda{|fn| fn.call}
      #  self['print']     = lambda{|msg| puts msg}
      #  self['fopen']     = lambda{|name, mode| File.open(name, mode)}
      #  self['new']       = lambda do
      #    new_runtime = self.class.new
      #    new_runtime['_eval'] = lambda{|script| new_runtime.eval(script)}
      #    new_runtime.eval('var t = new Function(); t._eval = __this__._eval;t;') 
      #  end
      #  self['HTTPConnection'] = HTTPConnection.new
    end
    
    def paths
      @paths ||= []
    end
    
    def add_to_path( file_path )
      new_path = file_path.match(/\.[a-z]+$/i) ? File.dirname( file_path ) : file_path
      paths << new_path unless paths.include?( new_path )
      self['Paths'] = paths
    end
    
    def load( file_path )
      add_to_path( file_path )
      super
    end
    
    def to_s
      "<#{self.class} ##{object_id}>"
    end
  end
  
  class HTTPConnection
    def connect(host, port)
      Net::HTTP.start(host, port)
    end
    
    def request(httpMethod, path)
      klass = case httpMethod
      when "GET" 
        Net::HTTP::Get
      when "PUT"
        Net::HTTP::Put
      when "POST"
        Net::HTTP::Post
      when "HEAD"
        Net::HTTP::Head
      when "DELETE"
        Net::HTTP::Delete
      end
      klass.new(path) if klass
    end
    
    def go(connection, request, headers, data)
      headers.each do |key,value| 
        request.add_field(key,value)
      end
      response, body = connection.request(request, data)
      respheaders = Hash.new
      response.each_header do |name, value|
        respheaders.store(name, value)
      end
      response['body'] = body
      [response, respheaders]
    end
    
    def finish(connection)
      connection.finish if connection.started?
    end
  end
end
