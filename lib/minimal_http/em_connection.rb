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

  def unbind
    @stream << '' if @stream
  end
  
  def <<(output_data)
    if @streaming_body
      @buffer << output_data
    elsif output_data.is_a?(MinimalHttp::StreamingBody)
      setup_streaming_body!(output_data)
    else
      body_chunk!(output_data)
    end
  end
  
  def body_chunk!(output_data)
    case output_data
    when String
      send_data(output_data)
    when nil
      close_connection(true)
      body_complete!(discard_buffer)
    else
      puts "Bad output chunk #{output_data.inspect}"
    end  
  end
  
  def body_complete!(discard_buffer = false)
    @streaming_body = nil
    old_buffer = @buffer
    @buffer = nil
    
    unless discard_buffer
      # note, this will work even if the buffer contains more bodies
      old_buffer.each { |buffered| self << buffered }
    end
  end
  
  private
  
  def setup_streaming_body!(body)
    @streaming_body = body
    @buffer = []
    @streaming_body.start_streaming!(self)
  end
  
end
