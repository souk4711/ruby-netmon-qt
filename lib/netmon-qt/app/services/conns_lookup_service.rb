class ConnsLookupService
  def perform
    ino2conn = {}
    conns = []

    %w[tcp tcp6 udp udp6].each do |protocol|
      str = File.read("/proc/net/#{protocol}")
      sockets = Netmon::ProcNet.sockets_form_str(str)
      sockets.each do |socket|
        conn = Netmon::Connection.new(socket)
        conn.protocol = protocol
        conns << conn
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
end
