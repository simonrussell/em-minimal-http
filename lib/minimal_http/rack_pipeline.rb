# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::RackPipeline < MinimalHttp::Pipeline

  def initialize(app, *args)
    super(*args)
    
    @app = app  
  end
  
  def <<(request)
    puts request.inspect
    
    env = {
      'REQUEST_METHOD' => request.http_method,
      'SERVER_NAME' => request.server_name,
      'SERVER_PORT' => request.server_port,
      'SCRIPT_NAME' => '',
      'PATH_INFO' => request.request_url,
      'QUERY_STRING' => request.query_string,
      
      'rack.version' => [1,1],
      'rack.url_scheme' => 'http',
      'rack.input' => StringIO.new(request.body),
      'rack.errors' => $stderr,
      'rack.multithread' => true,
      'rack.multiprocess' => false,
      'rack.run_once' => false
    }
    
    rack_response = @app.call(env)
    @response_renderer << request.response(*rack_response)
  end
  
  class Factory
    def initialize(app)
      @app = app
    end
    
    def new(*args)
      MinimalHttp::RackPipeline.new(@app, *args)
    end
  end
  
  def self.factory(app_class)
    Factory.new(app_class)
  end
  
end
