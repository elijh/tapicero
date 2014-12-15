##
## TAPICERO PROCESS MANIPULATION
##

module TapiceroProcess

  public

  def self.run_with_config(config_path)
    if running?
      if config_path != config_of_running_tapicero()
        kill
        start(config_path)
      end
    else
      start(config_path)
    end
  end

  def self.start(config_path)
    Dir.chdir(base_dir) do
      other_process = fork do
        if DEBUG
          puts "bin/tapicero run -- '#{config_path}'"
          exec "bin/tapicero run -- '#{config_path}'"
        else
          exec "bin/tapicero run -- '#{config_path}' > /dev/null | grep -v ^tapicero:"
        end
      end
      Process.detach(other_process)
      10.times do
        sleep 0.1
        break if get_pid
      end
      if !running?
        puts 'Tapicero should be running'
        exit 1
      end
    end
  end

  # kill everything, not just the ones we started
  def self.kill!
    kill # first try the pid file method
    pids = `pgrep -f 'bin/tapicero'`.strip
    if !pids.empty?
      pids.gsub!("\n", " ")
      puts "Killing all bin/tapicero #{pids}" if DEBUG
      `pkill -f 'bin/tapicero'`
    end
  end

  def self.kill
    pid = get_pid
    if pid
      puts "Killing bin/tapicero #{pid}" if DEBUG
      Process.kill("TERM", pid)
      10.times do
        sleep 0.1
        break if get_pid.nil?
      end
      if running?
        puts 'Tapicero could not be killed'
        exit 1
      end
    end
  end

  private

  def self.base_dir
    File.expand_path('../../..', __FILE__)
  end

  def self.pid_file
    '/tmp/tapicero.pid'
  end

  def self.get_pid
    if File.exists?(pid_file)
      pid = File.read(pid_file).strip
      if pid !~ /^\d+/
        puts "Bad #{pid_file}: Remove the file and try again.";
        exit(1)
      else
        return pid.to_i
      end
    else
      return nil
    end
  end

  def self.running?
    return false if !File.exists?(pid_file)
    pid = get_pid()
    begin
      Process.kill(0, pid)
      return pid
    rescue Errno::EPERM
      puts "Failed to test tapicero pid: No permission to query #{_id}!"
      exit(1)
    rescue Errno::ESRCH
      puts "Bad #{pid_file}: #{pid} is NOT running. Remove the file and try again.";
      exit(1)
    rescue
      puts "Unable to determine status for tapicero process #{pid} : #{$!}"
      exit(1)
    end
  end

  #
  # returns the path of the currently running tapicero.
  #
  def self.config_of_running_tapicero
    config = `ps -o cmd= --pid #{get_pid}`.split('--')[1]
    if config.nil?
      puts "Could not determine config file of currently running tapicero. Please kill it and rerun the tests."
    else
      return config.strip.gsub("'", '')
    end
  rescue StandardError => ex
    puts "Could not parse running tapicero options: #{ex}"
    exit 1
  end

end
