# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::HelloWorldPipeline < MinimalHttp::Pipeline

  def <<(request)
    puts request.inspect
    @response_renderer << request.response(200, {'Content-Type' => 'text/plain'}, ['hello world'])
  end

end
