#apiget.rb

module Puppet::Parser::Functions
  newfunction(:apiget, :type => :rvalue) do |args|
    require 'net/http'
    require 'net/https'
    url = "https://#{args[0]}.logicmonitor.com/santaba#{args[3]}&c=#{args[0]}&u=#{args[1]}&p=#{args[2]}"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(req)
    return response.body
  end
end
