require 'spec_helper'

describe MinimalHttp::RequestParser do

  # we don't really want to test http_parser.rb, but we're putting just enough here to test our uses of it
  
  let(:client_ip) { Faker::Internet.ip_v4_address }
  
  let(:input) { '' }
  let(:output) { [] }
  let(:parser) { MinimalHttp::RequestParser.new(client_ip, output) }  
  
  let(:parsed_request) do
    parser << input
    output.length.should == 1
    output.first.should_not be_keep_alive
    output.first
  end
  
  let(:parsed_requests) do
    parser << input
    output
  end
  
  describe "parsed request" do
    subject { parsed_request }
    
    context "with valid request" do
      let(:http_version) { %w(1.0 1.1).sample }
      let(:http_method) { %w(GET HEAD).sample }
      let(:request_url) { "/#{Faker::Internet.domain_word}/#{Faker::Internet.domain_word}" }
      let(:headers) { { "Host" => Faker::Internet.domain_name, "Connection" => "Close" } }
      
      let(:input) { "#{http_method} #{request_url} HTTP/#{http_version}\r\n#{headers.map { |k, v| "#{k}: #{v}\r\n" }.join('')}\r\n" }

      its(:client_ip) { should == client_ip }
      its(:request_url) { should == request_url }
      its(:http_version) { should == http_version }
      its(:http_method) { should == http_method }
      its(:headers) { should == headers }
    end
    
    context "with invalid request" do
      let(:input) { "aslklsajflsakdjflaskdjf\r\n\r\n" }
      
#      its(:client_ip) { should == client_ip }
      it { should == MinimalHttp::Request::BAD_REQUEST }
    end
    
  end

  describe "multiple requests" do
    let(:input) do
      "GET / HTTP/1.1\r\n\r\n" +
      "HEAD /blah HTTP/1.1\r\nConnection: Close\r\n\r\n"
    end
    
    describe "first request" do
      subject { parsed_requests[0] }
    
      its(:client_ip) { should == client_ip }
      its(:http_method) { should == 'GET' }
      its(:request_url) { should == '/' }
      it { should be_keep_alive }
    end
    
    describe "second request" do
      subject { parsed_requests[1] }
      
      its(:client_ip) { should == client_ip }
      its(:http_method) { should == 'HEAD' }
      its(:request_url) { should == '/blah' }
      it { should_not be_keep_alive }
    end
    
    describe "number of requests" do
      subject { parsed_requests }
      its(:length) { should == 2 }
    end
  end

end
