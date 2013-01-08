# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

# TODO this will be split out into different types of streaming bodies

class MinimalHttp::StreamingBody

  def initialize
    @buffer = []
    @closed = false
  end
  
  def start_streaming!(connection)
    @connection = connection
    @buffer.each { |buffered| @connection.body_chunk!(buffered) }
    @connection.body_complete! if @closed
    @buffer = nil
  end
  
  def <<(output_data)
    if @buffer
      @buffer << output_data
    else
      @connection.body_chunk!(output_data)
    end
  end
  
  def close
    if @buffer
      @closed = true
    else
      @connection.body_complete!
    end
  end
  
end
