# Copyright (c) 2013 Simon Russell.  See LICENCE for details.

class MinimalHttp::Response
  
  attr_reader :timestamp
  attr_reader :request, :status_code, :headers, :body
  
  def initialize(request, status_code, headers, body)
    @timestamp = Time.now
    @request = request
    @status_code = status_code.to_i
    @headers = headers
    @body = body
  end
  
  # http://tools.ietf.org/html/rfc2616#section-6.1.1
  STATUS_MESSAGES = {
    100 => 'Continue',
    101 => 'Switching Protocols',

    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',

    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    307 => 'Temporary Redirect',
    
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request URI Too Large',
    415 => 'Unsupported Media Type',
    416 => 'Requested Range Not Satisfiable',
    417 => 'Expectation Failed',
    
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported'
  }
  
  def status_message
    STATUS_MESSAGES.fetch(@status_code) { "Unknown Status #{@status_code}" }
  end
  
end
