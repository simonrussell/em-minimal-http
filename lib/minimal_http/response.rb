# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::Response
  
  attr_reader :request, :status_code, :headers, :body
  
  def initialize(request, status_code, headers, body)
    @request = request
    @status_code = status_code
    @headers = headers
    @body = body
  end
  
end
