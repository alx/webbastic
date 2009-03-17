module Merb
  module Rack
    class PageSlug < Merb::Rack::Middleware

      # :api: private
      def initialize(app,directory)
        super(app)
        @static_server = ::Rack::File.new(directory)
      end
      
      # :api: plugin
      def call(env)        
        path = if env[Merb::Const::PATH_INFO]
                 env[Merb::Const::PATH_INFO].gsub(Merb::Const::SLASH, "")
               else
                 Merb::Const::EMPTY_STRING
               end
        
        # Verify path doesn't contain extension (won't be a page slug)
        # and get the header corresponding to the slug if it exists
        if File.extname(path).empty? && 
           header = ::Webbastic::Header.first(:name => 'page-slug', :content => path)
          
          path = page_path(header.page)
          
          # Serve the file if it's there and the request method is GET or HEAD
          if file_exist?(path) && env[Merb::Const::REQUEST_METHOD] =~ /GET|HEAD/ 
            # pass new path to the server
            env[Merb::Const::PATH_INFO] = path
            @static_server.call(env)
          end
        end
        @app.call(env)
      end
      
      def page_path(page)
        path = page.name.gsub(".txt", "") << ".html"
        path
      end
      
      # ==== Parameters
      # path<String>:: The path to the file relative to the server root.
      #
      # ==== Returns
      # Boolean:: True if file exists under the server root and is readable.
      #
      # :api: private
      def file_exist?(path)
        full_path = ::File.join(@static_server.root, ::Merb::Parse.unescape(path))
        ::File.file?(full_path) && ::File.readable?(full_path)
      end
    end
  end
end