require 'java'
require 'unidata/asjava.jar'
require 'unidata/extensions'
require 'unidata/select_list'
require 'unidata/connection'
require 'unidata/field'
require 'unidata/model'
require "unidata/version"

module Unidata
  include_package 'asjava.uniobjects'
  include_package 'asjava.uniclientlibs'

  class << self
    attr_reader :connection

    def unijava
      @unijava ||= Unidata::UniJava.new
    end

    def prepare_connection(config={})
      @connection = Connection.new(config[:user], config[:password], config[:host], config[:data_dir])
    end

    def open_connection
      begin
        @connection.open
        yield if block_given?
      ensure
        close_connection if block_given?
      end
    end

    def close_connection
      @connection.close
    end
  end
end
