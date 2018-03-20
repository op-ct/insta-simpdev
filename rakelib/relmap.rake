
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


def get_iso
http_get 'http://isoredirect.centos.org/centos/7/isos/x86_64/'
  require 'simp/build/release_mapper'
    @mappings_path = File.expand_path( 'files/release_mappings.yaml', File.dirname(__FILE__) )
    @mapper        = Simp::Build::ReleaseMapper.new( '5.1.X', @mappings_path )
      mapper = Simp::Build::ReleaseMapper.new( '4.2.X', @mappings_path, true )
      data = mapper.autoscan_unpack_list(path_string)
require 'pry'; binding.pry
end

namespace :build do
  desc 'FIXME: cjt WIP retrieve the ISO'
  task :get_iso do
    get_iso
  end
end

