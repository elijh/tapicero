#
# monkeypatch CouchRest::Streamer to fix
# https://github.com/couchrest/couchrest/pull/104
#
module CouchRest
  class Streamer

    def open_pipe(cmd, &block)
      first = nil
      prev = nil
      IO.popen(cmd) do |f|
        while line = f.gets
          row = parse_line(line)
          if row.nil?
            first ||= line # save the header for later if we can't parse it.
          else
            block.call row
          end
          prev = line
        end
      end

      raise RestClient::ServerBrokeConnection if $? && $?.exitstatus != 0

      parse_first(first, prev)
    end

  end
end
