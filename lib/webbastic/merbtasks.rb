namespace :slices do
  namespace :webbastic do
  
    desc "Install Webbastic"
    task :install => [:preflight, :setup_directories, :copy_assets, :migrate]
    
    desc "Test for any dependencies"
    task :preflight do # see slicetasks.rb
    end
  
    desc "Setup directories"
    task :setup_directories do
      puts "Creating directories for host application"
      Webbastic.mirrored_components.each do |type|
        if File.directory?(Webbastic.dir_for(type))
          if !File.directory?(dst_path = Webbastic.app_dir_for(type))
            relative_path = dst_path.relative_path_from(Merb.root)
            puts "- creating directory :#{type} #{File.basename(Merb.root) / relative_path}"
            mkdir_p(dst_path)
          end
        end
      end
    end
    
    # desc "Copy stub files to host application"
    # task :stubs do
    #   puts "Copying stubs for Webbastic - resolves any collisions"
    #   copied, preserved = Webbastic.mirror_stubs!
    #   puts "- no files to copy" if copied.empty? && preserved.empty?
    #   copied.each { |f| puts "- copied #{f}" }
    #   preserved.each { |f| puts "! preserved override as #{f}" }
    # end
    
    # desc "Copy stub files and views to host application"
    # task :patch => [ "stubs", "freeze:views" ]
  
    desc "Copy public assets to host application"
    task :copy_assets do
      
      Webbastic.push_path(:flash, Webbastic.dir_for(:public) / "flash", nil)
      Webbastic.push_app_path(:flash, Webbastic.app_dir_for(:public) / "flash", nil)
      
      puts "Copying assets for Webbastic - resolves any collisions"
      components = Webbastic.mirrored_public_components + [:flash]
      copied, preserved = Webbastic.mirror_files_for(components)
      puts "- no files to copy" if copied.empty? && preserved.empty?
      copied.each { |f| puts "- copied #{f}" }
      preserved.each { |f| puts "! preserved override as #{f}" }
    end
    
    desc "Migrate the database"
    task :migrate do # see slicetasks.rb
    end
    
    desc "Freeze Webbastic into your app (only webbastic/app)" 
    task :freeze => [ "freeze:app" ]

    namespace :freeze do
      
      # desc "Freezes Webbastic by installing the gem into application/gems"
      # task :gem do
      #   ENV["GEM"] ||= "webbastic"
      #   Rake::Task['slices:install_as_gem'].invoke
      # end
      
      desc "Freezes Webbastic by copying all files from webbastic/app to your application"
      task :app do
        puts "Copying all webbastic/app files to your application - resolves any collisions"
        copied, preserved = Webbastic.mirror_app!
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freeze all views into your application for easy modification" 
      task :views do
        puts "Copying all view templates to your application - resolves any collisions"
        copied, preserved = Webbastic.mirror_files_for :view
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freeze all models into your application for easy modification" 
      task :models do
        puts "Copying all models to your application - resolves any collisions"
        copied, preserved = Webbastic.mirror_files_for :model
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
      desc "Freezes Webbastic as a gem and copies over webbastic/app"
      task :app_with_gem => [:gem, :app]
      
      desc "Freezes Webbastic by unpacking all files into your application"
      task :unpack do
        puts "Unpacking Webbastic files to your application - resolves any collisions"
        copied, preserved = Webbastic.unpack_slice!
        puts "- no files to copy" if copied.empty? && preserved.empty?
        copied.each { |f| puts "- copied #{f}" }
        preserved.each { |f| puts "! preserved override as #{f}" }
      end
      
    end
    
  end
end