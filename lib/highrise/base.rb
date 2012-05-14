require 'active_resource'

module Highrise
  class Base < ActiveResource::Base
    
    self.format = :xml #Higrise API only works with xml and not JSON
    
    def self.url_for(n)
      base  = site.to_s.split('@')[1]
      File.join('https://', base, element_path(n)).gsub(".xml",'')
    end

    protected

    # Fix for ActiveResource 3.1+ errors
    self.format = :xml

    # Dynamic finder for attributes
    def self.method_missing(method, *args)
      if method.to_s =~ /^find_(all_)?by_([_a-zA-Z]\w*)$/
        raise ArgumentError, "Dynamic finder method must take an argument." if args.empty?
        options = args.extract_options!
        resources = respond_to?(:find_all_across_pages) ? send(:find_all_across_pages, options) : send(:find, :all)
        resources.send($1 == 'all_' ? 'select' : 'detect') { |container| container.send($2) == args.first }
      else
        super
      end
    end
   
  end
end
