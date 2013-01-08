# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::Pipeline
  
  def initialize(response_renderer)
    @response_renderer = response_renderer
  end
  
  def <<(request)
    if request.http_method == 'BADREQUEST'
      @response_renderer << request.response(400, {'Content-Type' => 'text/plain'}, ['Bad Request'])
    else
      @response_renderer << handle(request)
    end
  end
    
end
