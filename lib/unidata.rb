require 'udjrb'
require 'time'
require 'date'
require 'bigdecimal'
require 'unidata/extensions'
require 'unidata/connection'
require 'unidata/field'
require 'unidata/model'
require "unidata/version"

module Unidata
  class << self
    attr_reader :connection

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

