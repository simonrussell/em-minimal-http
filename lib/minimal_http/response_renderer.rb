# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::ResponseRenderer
  
  def initialize(response_stream)
    @output = response_stream    
  end
  
  def <<(response)
    request = response.request
       
    @output << "HTTP/#{request.http_version} #{response.status_code} #{response.status_message}\r\n"
    
    response.headers.each do |k, v|
      @output << "#{k}: #{v}\r\n"
    end

    if response.body.is_a?(MinimalHttp::StreamingBody)
      @output << "Connection: close\r\n"
      @output << "\r\n"
      @output << response.body
      @output << nil  # close connection
      
      log_response(response)
    else
      unless request.keep_alive?
        @output << "Connection: close\r\n"
      end

      body_size = 0
      response.body.each do |body_part|
        body_size += body_part.bytesize
      end

      @output << "Content-Length: #{body_size}\r\n"
      @output << "\r\n"

      response.body.each do |body_part|
        @output << body_part
      end
  
      @output << nil unless request.keep_alive?  # close the stream

      log_response(response, body_size)
    end
    
  end
  
  private
  
  def log_response(response, length = nil)
    request = response.request  
    time_elapsed = (response.timestamp - request.timestamp).round(4)
    
    puts %(#{request.client_ip} - - [#{Time.now.strftime('%d/%b/%Y:%H:%M:%S %z')}] "#{request.http_method} #{request.request_url} HTTP/#{request.http_version}" #{response.status_code} #{length || '-'} #{time_elapsed})
  end
  
end
