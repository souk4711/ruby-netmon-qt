class ConnsTableView < RubyQt6::Bando::QWidget
  class Store
    DataItem = Struct.new(:keyitem)

    attr_reader :itemmodel

    def initialize
      @dataitems = {}

      @itemmodel = QStandardItemModel.new
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

        pname = conn.comm.nil? ? "" : conn.comm
        pid = conn.pid.nil? ? "" : conn.pid.to_s
        @itemmodel.append_row(
          keyitem,
          initialize_standarditem(initialize_icon_process(pname), pname),
          initialize_standarditem(pid),
          initialize_standarditem(conn.protocol),
          initialize_standarditem(conn.state),
          initialize_standarditem(conn.uname),
          initialize_standarditem(conn.local_address),
          initialize_standarditem(conn.local_port.to_s),
          initialize_standarditem(conn.remote_address),
          initialize_standarditem(conn.remote_port.to_s)
        )
      end
    end

    private

    def initialize_standarditem(*args)
      item = QStandardItem.new(*args)
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
        when "" then "question"
        else pname
        end
      QIcon.from_theme(name)
    end
  end
end
