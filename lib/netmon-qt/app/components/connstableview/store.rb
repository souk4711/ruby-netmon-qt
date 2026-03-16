class ConnsTableView < RubyQt6::Bando::QWidget
  GEOLITE2_MMDB = "/usr/share/GeoIP/GeoLite2-Country.mmdb"

  COLUMN_CONNECTION_KEY = 0
  COLUMN_PROCESS_NAME = 1
  COLUMN_PROCESS_ID = 2
  COLUMN_PROTOCOL = 3
  COLUMN_STATE = 4
  COLUMN_USER = 5
  COLUMN_LOCAL_ADDRESS = 6
  COLUMN_LOCAL_PORT = 7
  COLUMN_REMOTE_ADDRESS = 8
  COLUMN_REMOTE_PORT = 9

  class Store
    DataItem = Struct.new(:keyitem)

    attr_reader :itemmodel

    def initialize(parent)
      @geoiolookup = MaxMind::DB.new(
        GEOLITE2_MMDB, mode: MaxMind::DB::MODE_MEMORY
      )

      @active_processes = Set.new
      @active_protocols = Set.new
        .add(Netmon::Connection::PROTOCOL_TCP4)
        .add(Netmon::Connection::PROTOCOL_TCP6)
        .add(Netmon::Connection::PROTOCOL_UDP4)
        .add(Netmon::Connection::PROTOCOL_UDP6)
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
      @active_protocols.sort
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
        next unless dataitem.nil?

        keyitem = initialize_standarditem(key)
        @dataitems[key] = DataItem.new(keyitem)

        pname = conn.comm.nil? ? "?" : conn.comm
        pid = conn.pid.nil? ? "?" : conn.pid.to_s
        @itemmodel.append_row(
          keyitem,
          initialize_standarditem(initialize_icon_process(pname), pname),
          initialize_standarditem(pid),
          initialize_standarditem(conn.protocol),
          initialize_standarditem(conn.state),
          initialize_standarditem(conn.uname),
          initialize_standarditem(initialize_icon_ipaddress(conn.local_address), conn.local_address),
          initialize_standarditem(conn.local_port.to_s),
          initialize_standarditem(initialize_icon_ipaddress(conn.remote_address), conn.remote_address),
          initialize_standarditem(conn.remote_port.to_s)
        )

        @active_processes.add(pname)
        @active_users.add(conn.uname)
      end
    end

    private

    def initialize_standarditem(*args)
      item = QStandardItem.new(*args.compact)
      item.set_editable(false)
      item.set_selectable(false)
      item
    end

    def initialize_icon_process(pname)
      name =
        case pname
        when "adb" then "android-file-transfer"
        when "fcitx5" then "fcitx"
        when "msedge" then "microsoft-edge"
        when "kdeconnectd" then "kdeconnect"
        when "?" then "question"
        else pname
        end
      QIcon.from_theme(name)
    end

    def initialize_icon_ipaddress(ipaddress)
      return if @geoiolookup.nil?

      islocal = Netmon.local_address?(ipaddress)
      return QIcon.from_theme(QIcon::ThemeIcon::Computer) if islocal

      record = @geoiolookup.get(ipaddress)
      return initialize_icon_ipaddress_unknown if record.nil?

      code = record.dig("country", "iso_code")&.downcase
      return initialize_icon_ipaddress_unknown if code.nil?

      file = "assets:/flags/#{code}.svg"
      return initialize_icon_ipaddress_unknown unless QFile.exists(file)

      QIcon.new(file)
    end

    def initialize_icon_ipaddress_unknown
      pixmap = QPixmap.new(36, 36)
      pixmap.fill(QColor.new(Qt::White))
      QIcon.new(pixmap)
    end
  end
end
