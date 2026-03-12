module Netmon
  module ProcNet
    def self.sockets_form_str(str)
      str.lines[1..].map do |line|
        linesplit = line.split
        local_address, local_port = linesplit[1].split(":")
        remote_address, remote_port = linesplit[2].split(":")

        {
          local_address: format_address(local_address),
          local_port: format_port(local_port),
          remote_address: format_address(remote_address),
          remote_port: format_port(remote_port),
          state: linesplit[3],
          uid: linesplit[7].to_i,
          inode: linesplit[9].to_i
        }
      end
    end

    def self.format_address(str)
      case str.size
      when 8 then str.scan(/.{2}/).map { |s| s.to_i(16) }.join(".")
      when 32 then str.scan(/.{4}/).join(":")
      else raise "Invalid address str: #{str}"
      end
    end

    def self.format_port(str)
      str.to_i(16)
    end
  end
end
