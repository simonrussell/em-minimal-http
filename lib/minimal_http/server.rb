# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::Server
  
  def initialize(interface, port, pipeline_class_or_rack_app)
    @interface = interface
    @port = port
    
    if pipeline_class_or_rack_app.respond_to?(:call)
      @pipeline_class = MinimalHttp::RackPipeline.factory(pipeline_class_or_rack_app)
    else
      @pipeline_class = pipeline_class_or_rack_app
    end
  end
  
  def start!
    @server_handle = EM.start_server @interface, @port, MinimalHttp::EmConnection do |conn|
      conn.pipeline_class = @pipeline_class
    end
  end
  
end
