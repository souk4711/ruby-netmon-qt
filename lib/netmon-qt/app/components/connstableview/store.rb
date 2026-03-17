class ConnsTableView < RubyQt6::Bando::QWidget
  # rubocop:disable Layout
  GEOLITE2_MMDB = "/usr/share/GeoIP/GeoLite2-Country.mmdb"

  COLUMN_CONNECTION_KEY = 0
  COLUMN_PROCESS_NAME   = 1
  COLUMN_PROCESS_ID     = 2
  COLUMN_PROTOCOL       = 3
  COLUMN_STATE          = 4
  COLUMN_USER           = 5
  COLUMN_LOCAL_ADDRESS  = 6
  COLUMN_LOCAL_PORT     = 7
  COLUMN_REMOTE_ADDRESS = 8
  COLUMN_REMOTE_PORT    = 9

  # Traffic Light Color Palette
  COLORS_TCP_STATE = {
    Netmon::Connection::STATE_ESTABLISHED => "#27AE60",
    Netmon::Connection::STATE_LISTEN      => "#2980B9",
    Netmon::Connection::STATE_SYN_SENT    => "#F1C40F",
    Netmon::Connection::STATE_SYN_RECV    => "#F1C40F",
    Netmon::Connection::STATE_FIN_WAIT1   => "#8E44AD",
    Netmon::Connection::STATE_FIN_WAIT2   => "#8E44AD",
    Netmon::Connection::STATE_CLOSING     => "#9B59B6",
    Netmon::Connection::STATE_CLOSE_WAIT  => "#E67E22",
    Netmon::Connection::STATE_LAST_ACK    => "#D35400",
    Netmon::Connection::STATE_TIME_WAIT   => "#7F8C8D",
    Netmon::Connection::STATE_CLOSE       => "#C0392B"
  }

  # Blue To Cyan Color Palette
  COLORS_UDP_STATE = {
    Netmon::Connection::STATE_ESTABLISHED => "#1ABC9C",
    Netmon::Connection::STATE_LISTEN      => "#3498DB",
    Netmon::Connection::STATE_SYN_SENT    => "#9B59B6",
    Netmon::Connection::STATE_SYN_RECV    => "#9B59B6",
    Netmon::Connection::STATE_FIN_WAIT1   => "#34495E",
    Netmon::Connection::STATE_FIN_WAIT2   => "#34495E",
    Netmon::Connection::STATE_CLOSING     => "#34495E",
    Netmon::Connection::STATE_CLOSE_WAIT  => "#34495E",
    Netmon::Connection::STATE_LAST_ACK    => "#34495E",
    Netmon::Connection::STATE_TIME_WAIT   => "#BDC3C7",
    Netmon::Connection::STATE_CLOSE       => "#95A5A6"
  }
  # rubocop:enable Layout

  class Store
    DataItem = Struct.new(:keyitem)

    attr_reader :itemmodel

    def initialize(parent)
      @geoiolookup = MaxMind::DB.new(
        GEOLITE2_MMDB, mode: MaxMind::DB::MODE_MEMORY
      )

      @active_processes = Set.new
      @active_protocols = Set.new
        .add(Netmon::Connection::PROTOCOL_TCP)
        .add(Netmon::Connection::PROTOCOL_UDP)
        .add(Netmon::Connection::PROTOCOL_TCP4)
        .add(Netmon::Connection::PROTOCOL_TCP6)
        .add(Netmon::Connection::PROTOCOL_UDP4)
        .add(Netmon::Connection::PROTOCOL_UDP6)
        .freeze
      @active_users = Set.new
        .add(Etc.getpwuid.name)

      @dataitems = {}
      @itemmodel = QStandardItemModel.new(parent)
      @itemmodel.set_horizontal_header_labels(
        QStringList.new
          .push("Connection Key")
          .push("Process Name")
          .push("Process ID")
          .push("Protocol")
          .push("State")
          .push("User")
          .push("Local Address")
          .push("Local Port")
          .push("Remote Address")
          .push("Remote Port")
      )

      refresh
    end

    def active_processes
      @active_processes.sort
    end

    def active_protocols
      @active_protocols.to_a
    end

    def active_users
      @active_users.sort
    end

    def refresh
      srv = ConnsLookupService.new
      conns = srv.perform

      removed = @dataitems.keys - conns.keys
      removed.each do |key|
        dataitem = @dataitems.delete(key)
        @itemmodel.remove_row(dataitem.keyitem.row)
      end

      conns.each do |key, conn|
        dataitem = @dataitems[key]
        dataitem.nil? ? refresh_additem(key, conn) : refresh_updateitem(dataitem, conn)
      end
    end

    private

    def initialize_standarditem(*args)
      item = QStandardItem.new(*args.compact)
      item.set_editable(false)
      item
    end

    def initialize_icon_process(comm)
      icon =
        case comm
        when "adb" then "android-file-transfer"
        when "fcitx5" then "fcitx"
        when "kdeconnectd" then "kdeconnect"
        when "msedge" then "microsoft-edge"
        when Netmon::Connection::COMM_DEFUNCT then "error"
        when Netmon::Connection::COMM_UNKNOWN then "question"
        else comm
        end
      icon = QIcon.from_theme(icon)
      icon.null? ? QIcon.from_theme("terminal") : icon
    end

    def initialize_icon_ipaddress(ipaddress)
      return if @geoiolookup.nil?

      islocal = Netmon.local_address?(ipaddress)
      return QIcon.from_theme(QIcon::ThemeIcon::Computer) if islocal

      record = @geoiolookup.get(ipaddress)
      return QIcon.from_theme("question") if record.nil?

      code = record.dig("country", "iso_code")&.downcase
      return QIcon.from_theme("question") if code.nil?

      file = "assets:/flags/#{code}.svg"
      return initialize_icon_non_existent unless QFile.exists(file)

      QIcon.new(file)
    end

    def initialize_icon_non_existent
      pixmap = QPixmap.new(36, 36)
      pixmap.fill(QColor.new(Qt::White))
      QIcon.new(pixmap)
    end

    def refresh_additem(key, conn)
      keyitem = initialize_standarditem(key)
      @dataitems[key] = DataItem.new(keyitem)

      comm = conn.comm_text
      @itemmodel.append_row(
        keyitem,
        initialize_standarditem(initialize_icon_process(comm), comm),
        initialize_standarditem(conn.pid_text),
        initialize_standarditem(conn.protocol),
        initialize_standarditem(conn.state),
        initialize_standarditem(conn.uname),
        initialize_standarditem(initialize_icon_ipaddress(conn.local_address), conn.local_address),
        initialize_standarditem(conn.local_port.to_s),
        initialize_standarditem(initialize_icon_ipaddress(conn.remote_address), conn.remote_address),
        initialize_standarditem(conn.remote_port.to_s)
      )

      @active_processes.add(comm)
      @active_users.add(conn.uname)

      refresh_updateitem_color(keyitem.index, conn.protocol, conn.state)
    end

    def refresh_updateitem(dataitem, conn)
      keyitem = dataitem.keyitem
      keyitemindex = keyitem.index

      {
        COLUMN_PROCESS_NAME => conn.comm_text,
        COLUMN_PROCESS_ID => conn.pid_text,
        COLUMN_STATE => conn.state,
        COLUMN_USER => conn.uname
      }.each do |column, text|
        item = @itemmodel.item_from_index(keyitemindex.sibling_at_column(column))
        item.set_text(text)
      end

      refresh_updateitem_color(keyitemindex, conn.protocol, conn.state)
    end

    def refresh_updateitem_color(keyitemindex, protocol, state)
      colors = protocol.include?("TCP") ? COLORS_TCP_STATE : COLORS_UDP_STATE
      color = QBrush.new(QColor.new(colors[state]))
      item = @itemmodel.item_from_index(keyitemindex.sibling_at_column(COLUMN_STATE))
      item.set_foreground(color)
    end
  end
end
