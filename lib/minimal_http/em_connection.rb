# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::EmConnection < EM::Connection

  attr_accessor :pipeline_class

  def receive_data(data)
    unless @stream
      @response_renderer = MinimalHttp::ResponseRenderer.new(self)
      @pipeline = @pipeline_class.new(@response_renderer)
      @stream = MinimalHttp::RequestParser.new(@pipeline)    
    end
  
    @stream << data
  end
  
  def <<(output_data)
    if output_data
      send_data(output_data)
    else
      close_connection(true)
    end
  end
  
end
