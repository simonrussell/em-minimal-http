# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

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
