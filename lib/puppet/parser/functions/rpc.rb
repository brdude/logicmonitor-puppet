# logicmonitor_rpc.rb
# A slightly more usable version of apiget.rb

module Puppet::Parser::Functions
  newfunction(:rpc, :type => :rvalue) do |args|
    action = args[0]
    arg_list = args[1]
    returnval = nil
    @company = lookupvar('logicmonitor::account')
    @user = lookupvar('logicmonitor::user')
    @password = lookupvar('logicmonitor::password')
    url = "https://#{@company}.logicmonitor.com/santaba/rpc/#{action}?"
    first_arg = true
    arg_list.each_pair do |key, value|
      url << "#{key}=#{value}&"
    end
    url << "c=#{@company}&u=#{@user}&p=#{@password}"
    uri = URI(url)
    begin
      http = Net::HTTP.new(uri.host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(req)
      returnval= response.body.to_s
    rescue SocketError => se
      notice( "There was an issue communicating with #{url}. Please make sure everything is correct and try again.")
    rescue Error => e
      notice( "There was an issue.")
      notice( e.message )
    end
    returnval
  end
end
