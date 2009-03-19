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
                 env[Merb::Const::PATH_INFO].gsub(/^\//, '')
               else
                 Merb::Const::EMPTY_STRING
               end
        
        Merb.logger.debug "[Merb::Rack::PageSlug] Path: #{path}"
        Merb.logger.debug "[Merb::Rack::PageSlug] File.extname(path).empty?: #{File.extname(path).empty?}"
        Merb.logger.debug "[Merb::Rack::PageSlug] path.slice().nil?: #{path.slice("/").nil?}"
        
        # Verify path doesn't contain extension (won't be a page slug)
        # and that it doesn't contain / char (no traversal)
        if !path.empty? && File.extname(path).empty? && path.slice("/").nil?
          
          Merb.logger.debug "[Merb::Rack::PageSlug] Get ::Webbastic::Header"
          
          # Get the header corresponding to the slug if it exists
          if header = ::Webbastic::Header.first(:name => 'page-slug', :content => path)
          
            path = page_path(header.page)
            
            Merb.logger.debug "[Merb::Rack::PageSlug] Page path: #{path}"
            
            # Serve the file if it's there and the request method is GET or HEAD
            if file_exist?(path) && env[Merb::Const::REQUEST_METHOD] =~ /GET|HEAD/ 
              # pass new path to the server
              env[Merb::Const::PATH_INFO] = path
              @static_server.call(env)
            end
            
          end
        end
        @app.call(env)
      end
      
      def page_path(page)
        Merb.logger.debug "[Merb::Rack::PageSlug] Build page path: #{page.name} << .html"
        page.name.gsub(".txt", "") + ".html"
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