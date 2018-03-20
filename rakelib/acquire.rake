

def http_get(url)
  require 'net/http'
  require 'uri'

  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)

  unless response.code_type == Net::HTTPOK
    fail "ERROR: could not GET url '#{url}':"
  end
require 'pry'; binding.pry
  # response.code
  # response.body
end



namespace :build do
  namespace :repos do
    desc <<-DESC.gsub(/^\s{6}/,'')
      FIXME: cjt WIP get the repos

      fetch repo, puppetfile to correct refs
    DESC
    task  :fetch do
    end
  end
end
