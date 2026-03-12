module Netmon
  class Connection
    STATE_TEXT = {
      "01" => "ESTABLISHED",
      "02" => "SYN_SENT",
      "03" => "SYN_RECV",
      "04" => "FIN_WAIT1",
      "05" => "FIN_WAIT2",
      "06" => "TIME_WAIT",
      "07" => "CLOSE",
      "08" => "CLOSE_WAIT",
      "09" => "LAST_ACK",
      "0A" => "LISTEN",
      "0B" => "CLOSING"
    }.freeze

    attr_accessor :protocol
    attr_accessor :local_address, :local_port
    attr_accessor :remote_address, :remote_port
    attr_accessor :state, :uid, :inode
    attr_accessor :pid, :comm

    def initialize(attrs)
      attrs.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end

    def state_text
      STATE_TEXT[state] || "UNKNOWN"
    end
  end
end
