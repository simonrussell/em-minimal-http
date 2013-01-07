require 'eventmachine'
require 'http/parser'

module MinimalHttp
end

class MinimalHttp::Response
  
  attr_reader :request, :status_code, :headers, :body
  
  def initialize(request, status_code, headers, body)
    @request = request
    @status_code = status_code
    @headers = headers.freeze
    @body = body.freeze
    freeze
  end
  
end

class MinimalHttp::Request
  
  attr_reader :http_version
  attr_reader :http_method
  attr_reader :request_url
  attr_reader :headers
  
  def initialize(info)
    @http_version = info.fetch(:http_version)
    @http_method = info.fetch(:http_method)
    @request_url = info.fetch(:request_url)
    @headers = info.fetch(:headers)
  end
  
  def response(*args)
    MinimalHttp::Response.new(self, *args)
  end
  
end


class MinimalHttp::RequestParser

  def initialize(pipeline)
    @pipeline = pipeline
    @parser = Http::Parser.new(self)
  end

  def <<(data)
    @parser << data
  end
  
  def on_message_complete
    @pipeline << MinimalHttp::Request.new(
                   http_version: @parser.http_version.join('.'),
                   http_method: @parser.http_method,
                   request_url: @parser.request_url,
                   headers: @parser.headers
                 )
  end

end

class MinimalHttp::ResponseRenderer
  
  def initialize(response_stream)
    @output = response_stream    
  end
  
  def <<(response)
    @output << "HTTP/1.0 #{response.status_code} Something\r\n"
    
    response.headers.each do |k, v|
      @output << "#{k}: #{v}\r\n"
    end
    
    @output << "\r\n"
    
    response.body.each do |body_part|
      @output << body_part
    end
    
    @output << nil  # close the stream
  end
  
end

class MinimalHttp::Pipeline
  
  def initialize(response_renderer)
    @response_renderer = response_renderer
  end
    
end

class MinimalHttp::HelloWorldPipeline < MinimalHttp::Pipeline

  def <<(request)
    puts request.inspect
    @response_renderer << request.response(200, {'Content-Type' => 'text/plain'}, ['hello world'])
  end

end

class MinimalHttp::RackPipeline < MinimalHttp::Pipeline

  def initialize(app, *args)
    super(*args)
    
    @app = app  
  end
  
  def <<(request)
    env = {}
    rack_response = @app.call(env)
    @response_renderer << request.response(*rack_response)
  end
  
  class Factory
    def initialize(app_class)
      @app_class = app_class
    end
    
    def new(*args)
      MinimalHttp::RackPipeline.new(@app_class.new, *args)
    end
  end
  
  def self.factory(app_class)
    Factory.new(app_class)
  end
  
end

class MinimalHttp::Server
  
  
end

class MinimalHttp::EmConnection < EM::Connection

  attr_accessor :pipeline_class

  def receive_data(data)
    unless @stream
      @response_renderer = MinimalHttp::ResponseRenderer.new(self)
      @pipeline = @pipeline_class.new(@response_renderer)
      @stream = MinimalHttp::RequestParser.new(@pipeline)    
    end
  
    @stream << data
  end
  
  def <<(output_data)
    if output_data
      send_data(output_data)
    else
      close_connection(true)
    end
  end
  
end
