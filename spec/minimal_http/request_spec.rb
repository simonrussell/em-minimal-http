require 'spec_helper'

describe MinimalHttp::Request do

  let(:http_version) { [[1,0], [1,1]].sample }
  let(:http_method) { %w(GET POST PUT HEAD).sample }
  let(:request_url) { "/#{Faker::Internet.domain_word}/#{Faker::Internet.domain_word}" }

  let(:host_header_name) { Faker::Internet.domain_name }
  let(:host_header_port) { rand(4000..5000) }
  let(:host_header) { host_header_port != 80 ? "#{host_header_name}:#{host_header_port}" : host_header_name }
  let(:headers) { { "Host" => host_header } }
  
  let(:body) { "" }
  
  let(:request) do
    MinimalHttp::Request.new(
      http_version: http_version,
      http_method: http_method,
      request_url: request_url,
      headers: headers,
      body: body
    )
  end
  
  describe "#server_name" do
    subject { request.server_name }
    
    context "with port" do
      it { should == host_header_name }
    end
    
    context "without port" do
      let(:host_header_port) { 80 }
      it { should == host_header_name }
    end
    
    context "without Host header" do
      let(:host_header) { nil }
      it { should == "unknown" }
    end
  end
  
  describe "#server_port" do
    subject { request.server_port }
    
    context "with port" do
      it { should == host_header_port.to_s }
    end
    
    context "without port" do
      let(:host_header_port) { 80 }
      it { should == host_header_port.to_s }
    end
    
    context "without Host header" do
      let(:host_header) { nil }
      it { should == "80" }
    end    
  end

end
