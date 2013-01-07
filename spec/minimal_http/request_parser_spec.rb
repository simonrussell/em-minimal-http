require 'spec_helper'

describe MinimalHttp::RequestParser do

  # we don't really want to test http_parser.rb, but we're putting just enough here to test our uses of it
  
  let(:input) { '' }
  let(:output) { [] }
  let(:parser) { MinimalHttp::RequestParser.new(output) }  
  
  let(:parsed_request) do
    parser << input
    output.length.should == 1
    output.first
  end
  
  describe "parsed request" do
    subject { parsed_request }
    
    context "with valid request" do
      let(:http_version) { %w(1.0 1.1).sample }
      let(:http_method) { %w(GET HEAD).sample }
      let(:request_url) { "/#{Faker::Internet.domain_word}/#{Faker::Internet.domain_word}" }
      let(:headers) { { "Host" => Faker::Internet.domain_name } }
      
      let(:input) { "#{http_method} #{request_url} HTTP/#{http_version}\r\n#{headers.map { |k, v| "#{k}: #{v}\r\n" }.join('')}\r\n" }

      its(:request_url) { should == request_url }
      its(:http_version) { should == http_version }
      its(:http_method) { should == http_method }
      its(:headers) { should == headers }
    end
    
    context "with invalid request" do
      let(:input) { "aslklsajflsakdjflaskdjf\r\n\r\n" }
      
      it { should be_nil }
    end
    
  end

end
