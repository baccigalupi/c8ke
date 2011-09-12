require 'set'

module C8ke
  class Browser < V8::Context
    def initialize
      super
      configure
      load( File.expand_path(File.dirname(__FILE__))  + '/c8ke.js' )
    end
    
    def configure
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
      self['print'] = lambda { |message| puts message }
      
    end
    
    
    def paths
      @paths ||= []
    end
    
    def add_path( file_path )
      new_path = file_path.match(/\.[a-z]+$/i) ? File.dirname( file_path ) : file_path
      paths << new_path unless paths.include?(new_path)
      self['Paths'] = paths
    end
    
    def load( file_path )
      add_path( file_path )
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
