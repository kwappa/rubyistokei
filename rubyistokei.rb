require 'bundler'
Bundler.require

require 'yaml'
require 'json'
require 'digest/sha1'

class Database
  def initialize(path)
    data_loaded = Dir[File.join(path, '*.yaml')].map do |yaml_path|
      hash = YAML.load_file(yaml_path)
      id = File.basename(yaml_path, '.yaml')
      hash.merge(id: id)
    end
    @data = data_loaded.sort_by do |entry|
      Digest::SHA1.digest(entry[:id])
    end
  end

  attr_reader :data
end

module Rubyistokei
  class Application < Sinatra::Application
    configure do
      set :protection, :except => :frame_options

      DATA_PATH = File.join(__dir__, 'data')
    end

    get '/' do
      haml :index
    end

    get '/timer' do
      haml :timer
    end

    get '/css/screen.css' do
      scss :screen
    end

    get '/data.json' do
      content_type :json
      database = Database.new(DATA_PATH)
      JSON.dump(database.data)
    end
  end
end
