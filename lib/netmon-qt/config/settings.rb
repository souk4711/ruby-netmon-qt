module NetmonQt
  class Settings
    def GET_mainwindow_geometry_and_restore_to(mainwindow)
      settings = QSettings.new
      mainwindow.restore_geometry(settings.value("MainWindow/geometry", QByteArray.new("")))
      mainwindow.restore_state(settings.value("MainWindow/windowState", QByteArray.new("")))
    end

    def PUT_mainwindow_geometry(mainwindow)
      settings = QSettings.new
      settings.set_value("MainWindow/geometry", mainwindow.save_geometry)
      settings.set_value("MainWindow/windowState", mainwindow.save_state)
    end

    def GET_connections_check_interval
      default_connections_check_interval
    end

    def GET_geolite2_mmdb
      default_geolite2_mmdb
    end

    private

    def default_connections_check_interval
      4_000
    end

    def default_geolite2_mmdb
      "/usr/share/GeoIP/GeoLite2-Country.mmdb"
    end
  end
end
