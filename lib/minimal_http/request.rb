# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::Request
  
  attr_reader :timestamp
  attr_reader :client_ip
  attr_reader :http_version
  attr_reader :http_method
  attr_reader :request_url
  attr_reader :headers
  attr_reader :body
  
  def initialize(info)
    @timestamp = Time.now
    @client_ip = info.fetch(:client_ip)
    @http_version = info.fetch(:http_version)
    @http_method = info.fetch(:http_method)
    @request_url = info.fetch(:request_url)
    @headers = info.fetch(:headers)
    @body = info.fetch(:body)
    @keep_alive = info.fetch(:keep_alive)
  end
  
  def keep_alive?
    @keep_alive  
  end
  
  def response(*args)
    MinimalHttp::Response.new(self, *args)
  end
  
  HOST_REGEX = /\A([^\:]+)(\:(\d+))?\z/
  
  def server_name
    if @headers['Host'] =~ HOST_REGEX
      $1
    else
      'unknown'
    end
  end
  
  def server_port
    if @headers['Host'] =~ HOST_REGEX
      $3 || '80'
    else
      '80'
    end
  end
  
  QUERY_REGEX = /\?([^\?]*)\z/
  
  def query_string
    if @request_url =~ QUERY_REGEX
      $1
    else
      ''
    end
  end
  
  BAD_REQUEST = new(client_ip: '0.0.0.0', http_version: '1.0', http_method: 'BADREQUEST', request_url: '', headers: {}, body: ''.encode!('ASCII-8BIT'), keep_alive: false)
  
end
