#!/usr/bin/ruby
# coding: utf-8
#
# <bitbar.title>Digitalocean</bitbar.title>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author>Alejandro Torres</bitbar.author>
# <bitbar.desc>List your Digitalocean droplets.</bitbar.desc>
# <bitbar.image>http://i.imgur.com/GV9FXrE.png</bitbar.image>
# <bitbar.dependencies>ruby</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/fulgorek/bitbar-digitaocean</bitbar.abouturl>

require 'json'
require 'net/https'

module DigitalOcean
  class Client
    BASE_URL = 'https://cloud.digitalocean.com'
    DIGITALOCEAN_API = 'https://api.digitalocean.com'

    attr_reader :access_token

    def initialize(options = {})
      @access_token = options[:access_token]
      @get = options[:get]
      init
    end

    def droplets
      fetch("#{DIGITALOCEAN_API}/v2/droplets")
      if @response['droplets'].empty?
        handle_no_droplets_error
      else
        process_droplets
      end
    end

    private

    def render_toolbar_icon
      puts '|image=iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAQAAAC1QeVaAAAA4klEQVQYGQXBMSuEAQAG4Oe77066H0CJ0tmkSAaFQbFjUUaT36AMSpKSbNhkNhmslCx3ZTAohYiUsjql83qeAqUOFiwaUvPh0qkvpQ5V9LkSERHxaQkl9HgREU/utUXECnAhomVaXZeGIxE/GsyKuFUFwK6IAw5EzKFboVBD3bu4r+jHqxb+lPhV+tZEgz4jBpUACiXOxG8BYMyEHxe+UPNg0DMDNkxjT8QkWBdxzLzYxo6IUWyK+DNc6DFuxpRrN+qWzegFa44osC+2wKOIb6uoVFV0nLjTRJc3becOvSh1/gGbP1qNI14GZAAAAABJRU5ErkJggg=='
      puts '---'
    end

    def render_info
      puts '---'
      puts "Create Droplet | href=#{BASE_URL}/droplets/new?size=512mb"
      puts "Web console | href=#{BASE_URL}"
    end

    def process_droplets
      @response['droplets'].map do |droplet|
        c = droplet['status'] == 'active' ? '#222222' : '#FF0000'
        t = "[#{droplet['networks']['v4'][0]['ip_address']}] #{droplet['name']}"
        s = (17 - t.split(' ').first.length + 2)
        text = t.gsub(' ', ' ' * s)
        puts text + "| href=#{BASE_URL}/droplets/#{droplet['id']} color=#{c}"
      end
    end

    def open_file_command
      "/usr/bin/open -t #{__FILE__}"
    end

    def init
      render_toolbar_icon
      unless @access_token.to_s.empty?
        self.send(@get) if defined? @get
      else
        puts 'No Access Token! | color=red'
        puts "Open config file | bash=\"#{open_file_command}\" refresh=true\n"
      end
      render_info
    end

    def handle_no_method_defined
      puts 'Method not found'
    end

    def handle_network_errors
      puts 'API Error!'
      exit
    end

    def handle_no_droplets_error
      puts 'No Droplets!'
    end

    def fetch(uri)
      uri = URI.parse(uri)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req = Net::HTTP::Get.new(uri.path, initheader = connection_options)
      response = https.request(req)
      handle_network_errors if response.code.to_i != 200
      @response = JSON.parse(response.body)
      @status = response.code.to_i
    end

    def connection_options
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{access_token}"
      }
    end
  end
end

DigitalOcean::Client.new({
  :access_token => '',
  :get => 'droplets'
})
