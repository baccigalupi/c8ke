
// Establishes conventions for the logger
Envjs.Configuration = {
  /** Please see each module for specific configuration options */
  //this is a short list of well knowns, but can always be extended
  logging:[
    {category:'Envjs.Core',                 level:'WARN'},
    {category:'Envjs.Core.REPL',            level:'WARN'},
    {category:'Envjs.DOM',                  level:'WARN'},
    {category:'Envjs.DOM.Node',             level:'WARN'},
    {category:'Envjs.DOM.NodeList',         level:'WARN'},
    {category:'Envjs.DOM.NamedNodeMap',     level:'WARN'},
    {category:'Envjs.DOM.Element',          level:'WARN'},
    {category:'Envjs.DOM.Document',         level:'WARN'},
    {category:'Envjs.DOM.EventTarget',      level:'WARN'},
    {category:'Envjs.Timer',                level:'WARN'},
    {category:'Envjs.Location',             level:'WARN'},
    {category:'Envjs.XMLHttpRequest',       level:'WARN'},
    {category:'Envjs.Parser',               level:'WARN'},
    {category:'Envjs.Parser.HTMLParser',    level:'WARN'},
    {category:'Envjs.Parser.XMLParser',     level:'WARN'},
    {category:'Envjs.HTML.FrameElement',    level:'WARN'},
    {category:'Envjs.Window',               level:'WARN'},
    {category:'Envjs.Platform',             level:'WARN'},
    {category:'root',                       level:'WARN'}
  ], 
  env : {
    dev:{},
    prod:{},
    test:{}
  }
};

Envjs.config = function(){
  var config, subconfig;
  if(arguments.length === 0){
    return Envjs.Configuration;
  }else if(arguments.length === 1 && typeof(arguments[0]) == "string"){
    return Envjs.Configuration[arguments[0]];
  }else{
    Envjs.Configuration[arguments[0]] =  arguments[1];
  }
  return this;//chain
};

Envjs.Logging = {};
(function($$Log){
  
  var loggerFactory = null;
  
  Envjs.logging = function(config){ return Envjs.config('logging', config); };

  Envjs.logger = function(category){
    if(!category){ return new $$Log.NullLogger(); }
    if(!$$Log.loggerFactory){
      $$Log.loggerFactory = new $$Log.Factory();
    }
    if($$Log.updated){
      $$Log.loggerFactory.updateConfig();
      $$Log.updated = false;
    }
    return $$Log.loggerFactory.create(category);
  };

  $$Log.Level = {
    DEBUG:0,
    INFO:1,
    WARN:2,
    ERROR:3,
    NONE:4
  };

  $$Log.NullLogger = function(){
    // for speed why bother implement the interface, just null the functions
    var nullFunction = function(){ return this; };
    Envjs.extend(this,  {
        debug : nullFunction,
        info : nullFunction,
        warn : nullFunction,
        error : nullFunction,
        exception : nullFunction
    });
  };
  
  $$Log.Logger = function(options){
    this.category   = "root";
    this.level      = null;
    Envjs.extend(this, options);
    try {
      this.level = $$Log.Level[ this.level ? this.level : "NONE"];
      this.appender = new $$Log.ConsoleAppender(options);
      return this;
    } catch(e) {
      return new $$Log.NullLogger();
    }
  };

  //All logging calls are chainable
  Envjs.extend($$Log.Logger.prototype, {
    debug: function(){
      if(this.level<=$$Log.Level.DEBUG){
        this.appender.append( "DEBUG", this.category, arguments );  
        return this;
      }else{ 
        this.debug = function(){ return this; }; 
      }
      return this;
    },
    
    info: function(){
      print(this.level + ' <= ' +  $$Log.Level.INFO );
      if(this.level<=$$Log.Level.INFO){
        this.appender.append("INFO",this.category,arguments);  
        return this;
      }else{ 
        this.info = function(){ return this;}; 
      }
      return this;
    },
    
    warn: function(){
      print("this.level:" + this.level + " <= " + "$$Log.Level.WARN:"  + $$Log.Level.WARN);
      if(this.level<=$$Log.Level.WARN){
        this.appender.append("WARN",this.category,arguments);  
        return this;
      } else { 
        this.warn = function(){return this;}; 
      }
      return this;
    },
    
    error: function(){
      if(this.level<=$$Log.Level.ERROR){
        this.appender.append("ERROR",this.category,arguments);  
        return this;
      } else { 
        this.error = function(){return this;}; 
      }
      return this;
    },
    
    exception: function(e){
      if(this.level < $$Log.Level.NONE){
        if(e){ 
          this.appender.append("EXCEPTION", this.category,e); 
          return this;
        }
      } else { 
        this.exception = function(){ return this; }; 
      }
      return this;
    }
  });

  /**
   * @constructor
   */
  $$Log.ConsoleAppender = function(options){
    Envjs.extend( this, options );
    try{
      this.formatter = new $$Log.FireBugFormatter(options);
      return this;
    } catch ( e ) {
      //Since the console and print arent available use a null implementation.
      throw e;
    }
    return this;
  };

  Envjs.extend( $$Log.ConsoleAppender.prototype, {
    append: function(level, category, message){
      switch(level){
        case ("DEBUG"):
          console.log.apply(console, this.formatter.format(level, category, message));
          break;
        case ("INFO"):
          console.info.apply(console, this.formatter.format(level, category, message));
          break;
        case ("WARN"):
          console.warn.apply(console, this.formatter.format(level, category, message));
          break;
        case ("ERROR"):
          console.error.apply(console,this.formatter.format(level, category, message));
          break;
        case ("EXCEPTION"):
          //message is e
          console.error.apply(console, this.formatter.format(level, category, 
              message.message?[message.message]:[])); 
          console.trace();
          break;
      }
    }
  });

  $$Log.FireBugFormatter = function(options){ Envjs.extend(this, options); };

  Envjs.extend( $$Log.FireBugFormatter.prototype, {
    getDateString : function(){
      return " ["+ new Date().toUTCString() +"] ";
    },
    
    format : function(level, category, objects){
      var msgPrefix = category + " "+level+": "+ this.getDateString();
      objects = (objects&&objects.length&&(objects.length>0))?objects:[];
      var msgFormat = (objects.length > 0)?objects[0]:null;
      if (typeof(msgFormat) != "string"){
        objects.unshift(msgPrefix);
      }else{
        objects[0] = msgPrefix + msgFormat;
      }
      return objects;
    }
  });
  
  $$Log.Factory = function(options){
    Envjs.extend(this,options);
    this.configurationId = 'logging';
    //The LogFactory is unique in that it will create its own logger
    //so that it's events can be logged to console or screen in a
    //standard way.
    this.logger = new $$Log.Logger({
      category:"Envjs.Logging.Factory",
      level:"INFO",
      appender:"Envjs.Logging.ConsoleAppender"
    });
    this.attemptedConfigure = false;
    this.clear();
    this.updateConfig();
  };

  Envjs.extend($$Log.Factory.prototype,  {
    clear: function(){
      this.logger.debug("Clearing Cache.");
      this.cache = null;
      this.cache = {};
      this.size = 0;
    },

    add: function(id, object){
      this.logger.debug("Adding To Cache: %s", id);
      if ( !this.cache[id] ){
        this.cache[id] = object;
        this.size++;
        return id;
      }
      return null;
    },

    remove: function(id){
      this.logger.debug("Removing From Cache id: %s", id);
      if(this.find(id)){
        return ( delete this.cache[id] ) ? --this.size : -1; 
      }return null;
    },

    find: function(id){
      this.logger.debug("Searching Cache for id: %s", id);
      return this.cache[id] || null;
    },

    getConfig: function(){
      if( !this.configuration ){
        //First look for an object name Envjs.Configuration
        this.logger.debug( "Configuration for <%s> has not been set explicitly or has been updated implicitly.",  this.configurationId );
        try{
          if(Envjs.Configuration[this.configurationId]){
            this.logger.debug("Found Envjs.Configuration");
            this.configuration = Envjs.Configuration[this.configurationId];
          }
        }catch(e){
          this.logger.exception(e);
          throw new Error('Logging Configuration Error');
        }
      }
      return this.configuration;
    },
    
    setConfig: function(id, configuration){
      this.logger.debug("Setting configuration");
      this.configuration = configuration;
      Envjs.Configuration[id] = configuration;
    },

    create: function(category){
      var  categoryParts,
           subcategory,
           loggerConf,
           rootLoggerConf,
           i;
      if(!this.configuration){
        //Only warn about lack of configuration once
        if(!this.attemptedConfigure){
          this.logger.warn("Claypool Logging was not initalized correctly. Logging will not occur unless initialized.");
        }
        this.attemptedConfigure = true;
        return new $$Log.NullLogger();
      } else {
        //Find the closest configured category
        categoryParts = category.split(".");
        for(i=0;i<categoryParts.length;i++){
          subcategory = categoryParts.slice(0,categoryParts.length-i).join(".");
          loggerConf = this.find(subcategory);
          if(loggerConf !== null){
            //The level is set by the closest subcategory, but we still want the 
            //full category to display when we log the messages
            loggerConf.category = category;
            //TODO: we need to use the formatter/appender specified in the config
            return new $$Log.Logger( loggerConf );
          }
        }
        
        //try the special 'root' category
        rootLoggerConf = this.find('root');
        this.logger.debug('root logging category is set to %s', rootLoggerConf);
        if(rootLoggerConf !== null){
          //The level is set by the closest subcategory, but we still want the 
          //full category to display when we log the messages
          rootLoggerConf.category = category;
          return new $$Log.Logger(rootLoggerConf);
        }
      }
      //No matching category found
      this.logger.warn("No Matching category: %s Please configure a root logger.", category);
      return new $$Log.NullLogger();
    },
    
    updateConfig: function(){
      var loggingConfiguration;
      var logconf;
      var i;
      try{
        this.logger.debug("Configuring Logging");
        this.clear();
        loggingConfiguration = this.getConfig()||[];
        for(i=0;i<loggingConfiguration.length;i++){
          try{
            logconf = loggingConfiguration[i];
            this.add( logconf.category, logconf );
          }catch(ee){
            this.logger.exception(ee);
            return false;
          }
        }
      }catch(e){
        this.logger.exception(e);
        throw new Error('Logging configuration error');
      }
      return true;
    }
  });

  Envjs.logging = function(){
    if(arguments.length === 0){ return Envjs.config('logging'); }
    else{
      Envjs.Logging.updated = true;
      return Envjs.config('logging', arguments[0]);
    }
  };
  
  //leaked globally intentionally
  log = Envjs.logger('root');
     
}( Envjs.Logging ));
