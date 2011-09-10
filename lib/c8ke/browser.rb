module C8ke
  class Browser < V8::Context
    include Config
    
    def initialize
      super
      configure_ruby
      configure_envjs
      # load( racer_path ) 
    end
    
    def racer_path
      vendor_path + "/rubyracer.js"
    end
    
    def vendor_path
      File.expand_path(File.dirname(__FILE__) + "/../vendor")
    end
    
    def configure_ruby
      # ruby = { 
      #   'gc' => lambda{ GC.start },
      # }
      # 
      # # add some important constants
      # [ 
      #   Kernel, Object, Module, Class, String, Array, Hash, 
      #   ENV, IO, STDIN, STDOUT, STDERR, ARGF, File, Dir, Time,
      #   RUBY_VERSION, RUBY_PLATFORM, RUBY_PATCHLEVEL, RUBY_REVISION, RUBY_DESCRIPTION,
      #   ARGV, RbConfig, Config, URI, Process
      # ].each {|c| ruby[c.to_s] = c }
      # 
      # # adding some globals that seem good
      # [ $stdin, $stdout, $stderr, $FILENAME, $LOAD_PATH ].each { |c| ruby[c.to_s] = c }
      # 
      # # adding Kernel methods
      # [ 
      #   'warn', 'eval', 'caller', 'puts', 'rand', 
      #   'exec', 'system', 'sleep', 'pp', 'object_id'
      # ].each { |m| ruby[m] = Kernel.method(m) }
      # 
      # ruby['ARGV'] ||= [nil]
      # ruby['CONFIG'] = CONFIG
      # 
      # self['Ruby'] = ruby
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
      # self['root_dir'] = vendor_path
    end
    
    def path
      @path ||= []
    end
    
    def load( file_path )
      new_path = File.expand_path( File.dirname( file_path ) )
      path << new_path unless path.include?( new_path )
      self['path'] = path 
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
