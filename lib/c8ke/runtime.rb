module C8ke
  class Runtime < V8::Context
    include Config
    
    def initialize
      super
      configure_ruby
      configure_envjs
    end
    
    def configure_ruby
      self['Ruby'] = { 'gc' => lambda{ GC.start } }
      
      # add some important constants
      [ 
        Kernel, Object, Module, Class, String, Array, Hash, ENV, IO,
        CONFIG, STDIN, STDOUT, STDERR, ARGF, File, Dir, Time,
        RUBY_VERSION, RUBY_PLATFORM, RUBY_PATCHLEVEL, RUBY_REVISION, RUBY_DESCRIPTION,
        ARGV, RbConfig, Config, URI
      ].each {|c| self['Ruby'][c.to_s] = c }
      
      # adding some globals that seem good
      [ $stdin, $stdout, $stderr, $FILENAME, $LOAD_PATH ].each { |c| self['Ruby'][c.to_s.gsub(/^\$/, '')] = c }
      
      # adding Kernel methods
      [ 
        'warn', 'eval', 'caller', 'puts', 'rand', 
        'exec', 'system', 'sleep', 'pp', 'object_id'
      ].each { |m| self['Ruby'][m] = Kernel.method(m) }
    end

    def configure_envjs
      self['__this__']  = self
      self['sync']      = lambda{|fn| Proc.new{|*args| fn.call(*args) }}
      self['spawn']     = lambda{|fn| fn.call}
      self['print']     = lambda{|msg| puts msg}
      self['fopen']     = lambda{|name, mode| File.open(name, mode)}
      self['new']       = lambda do
        new_runtime = self.class.new
        new_runtime['_eval'] = lambda{|script| new_runtime.eval(script)}
        new_runtime.eval('var t = new Function(); t._eval = __this__._eval;t;') 
      end
      self['HTTPConnection'] = HTTPConnection.new
      self['envjs_dir'] = File.expand_path(File.dirname(__FILE__) + "/../vendor/envjs")
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
