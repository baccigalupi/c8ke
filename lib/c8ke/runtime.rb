module C8ke
  class Runtime < V8::Context
    include Config
    
    def initialize
      super
      configure
    end
    
    def configure
      self['Ruby'] = {
        'gc' => lambda{ GC.start() },
        'CONFIG' => CONFIG
      }
      Module.included_modules.each{|x| 
        # puts "adding #{x}"
        self['Ruby'][x.to_s] = x
      }
      Module.constants.each{|x| 
        begin # sexp related constants fail to load
          self['Ruby'][x.to_s] = Kernel.eval(x.to_s) 
        rescue 
          nil 
        end
      }
      Kernel.global_variables.each{|x|
        # puts "adding global variable #{x}"
        self['Ruby'][x.to_s] = Kernel.eval(x.to_s)
      }
      Kernel.methods.each{|x| 
        # puts "adding method #{x}"
        self['Ruby'][x.to_s] = Kernel.method(x)
      }
      
      
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
