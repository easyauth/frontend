class ApplicationController < ActionController::Base
  require 'json'
  protect_from_forgery with: :exception

  protected

  def call_backend(uri, method, parameters)
  	require 'net/http'
    require 'uri'
    uri = URI.parse(uri) 
    request = case method
              when "POST"
                Net::HTTP::Post.new(uri) 
              when "GET"
                Net::HTTP::Get.new(uri)
              when "PATCH"
                Net::HTTP::Patch.new(uri)
              when "DELETE"
                Net::HTTP::Delete.new(uri)
              end
    request.body = parameters.to_json
    request['content-type'] = 'application/json'
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end
  end
end
