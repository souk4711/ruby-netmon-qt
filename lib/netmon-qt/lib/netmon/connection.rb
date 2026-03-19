module Netmon
  class Connection
    # rubocop:disable Layout
    PROTOCOL_TCP  = "TCP"
    PROTOCOL_UDP  = "UDP"
    PROTOCOL_TCP4 = "TCP v4"
    PROTOCOL_TCP6 = "TCP v6"
    PROTOCOL_UDP4 = "UDP v4"
    PROTOCOL_UDP6 = "UDP v6"

    STATE_ESTABLISHED = "ESTABLISHED"
    STATE_LISTEN      = "LISTEN"
    STATE_SYN_SENT    = "SYN_SENT"
    STATE_SYN_RECV    = "SYN_RECV"
    STATE_FIN_WAIT1   = "FIN_WAIT1"
    STATE_FIN_WAIT2   = "FIN_WAIT2"
    STATE_CLOSING     = "CLOSING"
    STATE_CLOSE_WAIT  = "CLOSE_WAIT"
    STATE_LAST_ACK    = "LAST_ACK"
    STATE_TIME_WAIT   = "TIME_WAIT"
    STATE_CLOSE       = "CLOSE"

    COMM_DEFUNCT = "<defunct>"
    COMM_UNKNOWN = "<unknown>"
    # rubocop:enable Layout

    attr_accessor :protocol
    attr_accessor :local_address, :local_port
    attr_accessor :remote_address, :remote_port
    attr_accessor :state, :uid, :inode
    attr_accessor :pid, :comm
    attr_accessor :created_at

    def initialize(attrs)
      attrs.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end

    def key
      "#{protocol}: #{local_address}:#{local_port} <=> #{remote_address}:#{remote_port}"
    end

    def uname
      Etc.getpwuid(uid).name
    end

    def pid_text
      return pid.to_s if pid
      inode.zero? ? COMM_DEFUNCT : COMM_UNKNOWN
    end

    def comm_text
      return comm if comm
      inode.zero? ? COMM_DEFUNCT : COMM_UNKNOWN
    end
  end
end
