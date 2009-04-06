module Webbastic
  module Helpers
    module Export
      
      class RsyncExport
        
        def initialize(options = {})
          
          raise Exception, "Missing parameter: ssh_user" if option[:ssh_user].nil?
          raise Exception, "Missing parameter: ssh_server" if option[:ssh_server].nil?
          
          #============================= OPTIONS ==============================#
          
          # == Options for local machine.
          ssh_app       = option[:ssh_app]       || 'ssh'
          rsync_app     = option[:rsync_app]     || 'rsync'

          exclude_file  = option[:exclude_file]  || '/path/to/.rsyncignore'
          dir_to_backup = option[:dir_to_backup] || '/folder/to/backup'
          log_file      = option[:log_file]      || '/var/log/rrsync.log'
          log_age       = option[:log_age]       || 'daily'

          @empty_dir    = option[:empty_dir]     || '/tmp/empty_rsync_dir/' #NEEDS TRAILING SLASH.
          
          # == Options for the remote machine.
          ssh_user      = option[:ssh_user]
          @ssh_server   = option[:ssh_server]
          ssh_port      = option[:ssh_port].empty? ? '' : "-e 'ssh -p #{option[:ssh_port]}'"
          backup_root   = option[:backup_root]   || '/path/on/remote/machine/to/backup/folder'
          backup_dir    = option[:backup_dir]    || backup_root + '/' + Time.now.strftime('%A').downcase
          rsync_verbose = option[:rsync_verbose] || '-v'
          rsync_opts    = option[:rsync_opts]    || "--force --ignore-errors --delete-excluded --exclude-from=#{exclude_file} --delete --backup --backup-dir=#{backup_dir} -a"
          
          #============================= COMMANDS ==============================#
          @rsync_cleanout_cmd = "#{rsync_app} #{rsync_verbose} #{ssh_port} --delete -a #{@empty_dir} #{ssh_user}@#{@ssh_server}:#{backup_dir}"
          @rsync_cmd = "#{rsync_app} #{rsync_verbose} #{ssh_port} #{rsync_opts} #{dir_to_backup} #{ssh_user}@#{@ssh_server}:#{backup_root}/current"
        end
        
        def export
          Merb.logger.info "Started running at: #{Time.now}"
          run_time = Benchmark.realtime do
            begin
              raise Exception, "Unable to find remote host (#{@ssh_server})" unless Ping.pingecho(@ssh_server)

              FileUtils.mkdir_p("#{@empty_dir}")
              Open3::popen3("#{rsync_cleanout_cmd}") { |stdin, stdout, stderr|
                tmp_stdout = stdout.read.strip
                tmp_stderr = stderr.read.strip
                Merb.logger.info("#{rsync_cleanout_cmd}\n#{tmp_stdout}") unless tmp_stdout.empty?
                Merb.logger.error("#{rsync_cleanout_cmd}\n#{tmp_stderr}") unless tmp_stderr.empty?
              }
              Open3::popen3("#{rsync_cmd}") { |stdin, stdout, stderr|
                tmp_stdout = stdout.read.strip
                tmp_stderr = stderr.read.strip
                Merb.logger.info("#{rsync_cmd}\n#{tmp_stdout}") unless tmp_stdout.empty?
                Merb.logger.error("#{rsync_cmd}\n#{tmp_stderr}") unless tmp_stderr.empty?
              }
              FileUtils.rmdir("#{@empty_dir}")
            rescue Errno::EACCES, Errno::ENOENT, Errno::ENOTEMPTY, Exception => e
              Merb.logger.fatal(e.to_s)
            end
          end
          logger.info("Finished running at: #{Time.now} - Execution time: #{run_time.to_s[0, 5]}")
        end
        
      end
      

    end
  end
end