require 'eventmachine'

module MinimalHttp
end

class MinimalHttp::Response
  
  attr_reader :status_code, :headers, :body
  
  def initialize(status_code, headers, body)
    @status_code = status_code
    @headers = headers.freeze
    @body = body.freeze
    freeze
  end
  
end

class MinimalHttp::Request
  
  def response(*args)
    MinimalHttp::Response.new(*args)
  end
  
end


class MinimalHttp::RequestParser

  def initialize(pipeline)
    @pipeline = pipeline
  end

  def <<(data)
    # TODO some parsing!
    @pipeline << MinimalHttp::Request.new
  end

end

class MinimalHttp::ResponseRenderer
  
  def initialize(response_stream)
    @output = response_stream    
  end
  
  def <<(response)
    puts response
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
  
  def <<(request)
    @response_renderer << request.response(200, {'Content-Type' => 'text/plain'}, ['hello world'])
  end
  
end

class MinimalHttp::Server
  
  
end

class MinimalHttp::EmConnection < EM::Connection
  
  def post_init
    @response_renderer = MinimalHttp::ResponseRenderer.new(self)
    @pipeline = MinimalHttp::Pipeline.new(@response_renderer)
    @stream = MinimalHttp::RequestParser.new(@pipeline)
  end
  
  def receive_data(data)
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
