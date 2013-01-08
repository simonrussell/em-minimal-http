# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::HelloWorldPipeline < MinimalHttp::Pipeline

  def handle(request)
    request.response(200, {'Content-Type' => 'text/plain'}, ['hello world'])    
  end

end
