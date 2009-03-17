use Merb::Rack::PageSlug, Merb.dir_for(:public)
use Merb::Rack::Static, Merb.dir_for(:public)

run Merb::Rack::Application.new