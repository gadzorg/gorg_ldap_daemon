#!/usr/bin/env ruby
# encoding: utf-8

require 'yaml'
require 'gorg_service'
require 'active_ldap'

$LOAD_PATH.unshift File.expand_path('..', __FILE__)

class GorgLdapDaemon
  path=File.expand_path("../../config/config.yml",__FILE__)
  RAW_CONFIG ||= YAML::load(File.open(path))
  ENV['GORG_LDAP_DAEMON_ENV']||="development"

  #Initialize running environment and dependencies
  # TODO Allow Logger overriding
  def initialize
    @gorg_service=GorgService.new
  end

  #Run the worker
  # Exit with Ctrl+C
  def run
    begin
      puts " [*] Waiting for messages. To exit press CTRL+C"
      self.start
      loop do
        sleep(1)
      end
    rescue SystemExit, Interrupt => _
      self.stop
    end
  end

  def start
    @gorg_service.start
  end

  def stop
    @gorg_service.stop
  end


  #Class methods
  def self.env
    ENV['GORG_LDAP_DAEMON_ENV'] || "development"
  end

  def self.config
    RAW_CONFIG[ENV['GORG_LDAP_DAEMON_ENV']]
  end

  def self.root
    File.dirname(__FILE__)
  end

  def self.logger
    unless @logger
      file = File.open(File.expand_path("../logs/#{self.env}.log",self.root), "a+")
      file.sync = true
#      @logger = Logger.new(file, 'daily')
      @logger = Logger.new(STDOUT)

    end
    @logger
  end
end

Dir[File.expand_path("../**/*.rb",__FILE__)].each {|file| require file }
Dir[File.expand_path("../../config/initializers/*.rb",__FILE__)].each {|file|require file }
