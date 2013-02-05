require 'active_resource'

module Highrise
  class Base < ActiveResource::Base
    
    self.format = :xml #Higrise API only works with xml and not JSON
    
    def self.url_for(n)
      base  = site.to_s.split('@')[1]
      File.join('https://', base, element_path(n)).gsub(".xml",'')
    end

    protected

    class << self
      # If headers are not defined in a given subclass, then obtain
      # headers from the superclass.
      # http://opensoul.org/blog/archives/2010/02/16/active-resource-in-practice/
      def headers
        if defined?(@headers)
          @headers
        elsif superclass != Object && superclass.headers
          superclass.headers
        else
          @headers ||= {}
        end
      end

      def oauth_token=(token)
        headers['Authorization'] = "Bearer #{token}"
      end
    end

    # Fix for ActiveResource 3.1+ errors
    self.format = :xml

    # Dynamic finder for attributes
    def self.method_missing(method, *args)
      if method.to_s =~ /^find_(all_)?by_([_a-zA-Z]\w*)$/
        raise ArgumentError, "Dynamic finder method must take an argument." if args.empty?
        options = args.extract_options!
        if respond_to? :search
          resources = search $2 => args.first
          $1 == 'all_' ? resources : resources.first
        else
          resources = respond_to?(:find_all_across_pages) ? find_all_across_pages(options) : find(:all)
          resources.send($1 == 'all_' ? 'select' : 'detect') { |container| container.send($2) == args.first }
        end
      else
        super
      end
    end
   
  end
end
