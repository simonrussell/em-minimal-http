# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

require 'stringio'

class MinimalHttp::RackPipeline < MinimalHttp::Pipeline

  def initialize(app, *args)
    super(*args)
    
    @app = app  
  end
  
  def handle(request)
    env = {
      'REQUEST_METHOD' => request.http_method.dup,
      'SERVER_NAME' => request.server_name,
      'SERVER_PORT' => request.server_port,
      'SCRIPT_NAME' => '',
      'PATH_INFO' => request.request_url.dup,
      'REQUEST_PATH' => request.request_url.dup,
      'REQUEST_URI' => request.request_url.dup,
      'QUERY_STRING' => request.query_string,
      
      'rack.version' => [1,1],
      'rack.url_scheme' => 'http',
      'rack.input' => StringIO.new(request.body),
      'rack.errors' => $stderr,
      'rack.multithread' => true,
      'rack.multiprocess' => false,
      'rack.run_once' => false
    }
    
    add_headers!(env, request)
    
    rack_response = catch(:streaming) { @app.call(env) }
    request.response(*rack_response)
  end
  
  class Factory
    def initialize(app)
      @app = app
    end
    
    def new(*args)
      MinimalHttp::RackPipeline.new(@app, *args)
    end
  end
  
  def self.factory(app)
    Factory.new(app)
  end
  
  private
  
  def add_headers!(env, request)
    request.headers.each do |header, value|
      env[map_header(header)] = value
    end
  end
  
  def map_header(header)
    header = "HTTP_#{header.upcase.gsub('-', '_')}"
    
    case header
    when 'HTTP_CONTENT_TYPE'
      'CONTENT_TYPE'
    when 'HTTP_CONTENT_LENGTH'
      'CONTENT_LENGTH'
    else
      header
    end
  end
  
end
