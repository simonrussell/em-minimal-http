# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::ResponseRenderer
  
  def initialize(response_stream)
    @output = response_stream    
  end
  
  def <<(response)
    @output << "HTTP/#{response.request.http_version} #{response.status_code} Something\r\n"
    
    response.headers.each do |k, v|
      @output << "#{k}: #{v}\r\n"
    end

    unless response.request.keep_alive?
      @output << "Connection: close\r\n"
    end
    
    body = ''
    response.body.each do |body_part|
      body << body_part
    end

    @output << "Content-Length: #{body.bytesize}\r\n"
    @output << "\r\n"
    @output << body
    
    @output << nil unless response.request.keep_alive?  # close the stream
  end
  
end
