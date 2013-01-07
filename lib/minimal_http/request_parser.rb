# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::RequestParser

  def initialize(pipeline)
    @pipeline = pipeline
    @parser = Http::Parser.new(self)
    @body = ''.encode!('ASCII-8BIT')
  end

  def <<(data)
    @parser << data
  end
  
  def on_body(data)
    @body << data
  end
  
  def on_message_complete
    request = MinimalHttp::Request.new(
                http_version: @parser.http_version.join('.'),
                http_method: @parser.http_method,
                request_url: @parser.request_url,
                headers: @parser.headers,
                body: @body
              )
  
    @pipeline << request
  end

end
