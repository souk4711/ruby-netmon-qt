module Netmon
  module ProcNet
    TCP_STATE = {
      "01" => Connection::STATE_ESTABLISHED,
      "02" => Connection::STATE_SYN_SENT,
      "03" => Connection::STATE_SYN_RECV,
      "04" => Connection::STATE_FIN_WAIT1,
      "05" => Connection::STATE_FIN_WAIT2,
      "06" => Connection::STATE_TIME_WAIT,
      "07" => Connection::STATE_CLOSE,
      "08" => Connection::STATE_CLOSE_WAIT,
      "09" => Connection::STATE_LAST_ACK,
      "0A" => Connection::STATE_LISTEN,
      "0B" => Connection::STATE_CLOSING
    }.freeze

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
          state: TCP_STATE[linesplit[3]],
          uid: linesplit[7].to_i,
          inode: linesplit[9].to_i
        }
      end
    end

    def self.format_address(str)
      case str.size
      when 8 then str.scan(/.{2}/).reverse.map { |s| s.to_i(16) }.join(".")
      when 32 then str.scan(/.{8}/).map { |s| s.scan(/.{2}/).reverse }.join.scan(/.{4}/).join(":")
      else raise "Invalid address str: #{str}"
      end
    end

    def self.format_port(str)
      str.to_i(16)
    end
  end
end
