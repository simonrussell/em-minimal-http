# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

# TODO this will be split out into different types of streaming bodies

class MinimalHttp::StreamingBody

  def initialize(parts)
    @parts = parts
  end
  
  def start_streaming!(connection)
    @connection = connection
    @parts.each { |part| @connection.body_chunk!(part) }
    @connection.body_complete!
  end

end
