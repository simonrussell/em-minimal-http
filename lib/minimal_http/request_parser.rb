# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::RequestParser

  EMPTY_BODY = ''.force_encoding('ASCII-8BIT').freeze

  def initialize(client_ip, pipeline)
    @client_ip = client_ip
    @pipeline = pipeline
    @parser = Http::Parser.new(self)
    @body = EMPTY_BODY
  end

  def <<(data)
    @parser << data
  rescue Http::Parser::Error
    # TODO logging
    @pipeline << MinimalHttp::Request::BAD_REQUEST
  end
  
  def on_body(data)
    @body = @body.dup if @body.frozen?
    @body << data
  end
  
  def on_message_complete
    request = MinimalHttp::Request.new(
                client_ip: @client_ip,
                http_version: @parser.http_version.join('.'),
                http_method: @parser.http_method,
                request_url: @parser.request_url,
                headers: @parser.headers,
                body: @body,
                keep_alive: @parser.keep_alive?
              )
              
    @body = EMPTY_BODY

    @pipeline << request    
  end

end
