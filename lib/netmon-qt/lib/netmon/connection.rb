module Netmon
  class Connection
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

    def key
      "#{protocol}: #{local_address}:#{local_port} <=> #{remote_address}:#{remote_port}"
    end

    def uname
      Etc.getpwuid(uid).name
    end
  end
end
