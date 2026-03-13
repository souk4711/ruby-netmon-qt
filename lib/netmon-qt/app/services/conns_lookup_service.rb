class ConnsLookupService
  def perform
    conns = {}
    ino2conn = {}

    %w[tcp tcp6 udp udp6].each do |filename|
      str = File.read("/proc/net/#{filename}")
      sockets = Netmon::ProcNet.sockets_form_str(str)
      sockets.each do |socket|
        conn = Netmon::Connection.new(socket)
        conn.protocol = conn_protocol(filename)
        conns[conn.key] = conn
        ino2conn[conn.inode] = conn
      end
    end

    Dir.glob("/proc/[1-9]*/fd/[1-9]*") do |dir|
      ino = File.stat(dir).ino
      conn = ino2conn[ino]
      next if conn.nil?

      conn.pid = dir.split("/")[2].to_i
      conn.comm = File.read("/proc/#{conn.pid}/comm").strip
    rescue Errno::EACCES, Errno::ENOENT
    end

    conns
  end

  def conn_protocol(str)
    case str
    when "tcp"
      Netmon::Connection::PROTOCOL_TCP4
    when "tcp6"
      Netmon::Connection::PROTOCOL_TCP6
    when "udp"
      Netmon::Connection::PROTOCOL_UDP4
    when "udp6"
      Netmon::Connection::PROTOCOL_UDP6
    else
      ""
    end
  end
end
