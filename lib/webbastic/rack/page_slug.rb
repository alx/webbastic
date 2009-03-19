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
                 env[Merb::Const::PATH_INFO]
               else
                 Merb::Const::EMPTY_STRING
               end
        
        Merb.logger.debug "[Merb::Rack::PageSlug] Path: #{path}"
        Merb.logger.debug "[Merb::Rack::PageSlug] File.extname(path).empty?: #{File.extname(path).empty?}"
        Merb.logger.debug "[Merb::Rack::PageSlug] path.slice().nil?: #{path.slice("/").nil?}"
        
        # Verify path doesn't contain extension (won't be a page slug)
        # and that it doesn't contain / char (no deep slug)
        if path != "/" && File.extname(path).empty? && path !~ /.*\//
          
          Merb.logger.debug "[Merb::Rack::PageSlug] Get ::Webbastic::Header"
          
          # Get the header corresponding to the slug if it exists
          if path = page_path_from_header(path)
            
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
      
      # ==== Parameters
      # slug<String>:: Slug to found in Webbastic::Headers
      #
      # ==== Returns
      # String:: Path of the static file corresponding to this slug
      #
      # :api: private
      def page_path_from_header(slug)
        if header = ::Webbastic::Header.first(:name => 'page-slug', :content => slug)
          Merb.logger.debug "[Merb::Rack::PageSlug] Build page path: #{header.page.name} << .html"
          return header.page.name.gsub(".txt", "") << ".html"
        end
        nil
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