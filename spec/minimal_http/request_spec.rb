require 'spec_helper'

describe MinimalHttp::Request do

  let(:client_ip) { Faker::Internet.ip_v4_address }

  let(:http_version) { %w(1.0 1.1).sample }
  let(:http_method) { %w(GET POST PUT HEAD).sample }
  let(:keep_alive) { [true, false].sample }
  
  let(:query_string) { "#{Faker::Internet.domain_word}=#{rand(1324)}" }
  let(:request_url) { ["/#{Faker::Internet.domain_word}/#{Faker::Internet.domain_word}", query_string].compact.join('?') }

  let(:host_header_name) { Faker::Internet.domain_name }
  let(:host_header_port) { rand(4000..5000) }
  let(:host_header) { host_header_port != 80 ? "#{host_header_name}:#{host_header_port}" : host_header_name }
  let(:headers) { { "Host" => host_header } }
  
  let(:body) { Faker::Company.bs }
  
  let(:request) do
    MinimalHttp::Request.new(
      client_ip: client_ip,
      http_version: http_version,
      http_method: http_method,
      request_url: request_url,
      headers: headers,
      body: body,
      keep_alive: keep_alive
    )
  end
  
  describe "accessors" do
    subject { request }
    
    its(:http_version) { should == http_version }
    its(:http_method) { should == http_method }
    its(:request_url) { should == request_url }
    its(:headers) { should == headers }
    its(:body) { should == body }
    its(:keep_alive?) { should == keep_alive }
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

  describe "#query_string" do
    subject { request.query_string }
    
    context "with query string" do
      let(:query_string) { "a=2&b=4" }
      it { should == query_string }
    end
    
    context "with empty query string" do
      let(:query_string) { '' }
      it { should == '' }
    end

    context "without query string" do
      let(:query_string) { nil }
      it { should == '' }
    end
  end

end
