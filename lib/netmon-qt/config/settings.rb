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

    def GET_geoip_country_mmdb
      default_geoip_country_mmdb
    end

    private

    def default_connections_check_interval
      4_000
    end

    def default_geoip_country_mmdb
      candidates = [
        "/usr/local/share/GeoIP/Country.mmdb",
        "/usr/local/share/GeoIP/GeoLite2-Country.mmdb",
        "/usr/share/GeoIP/Country.mmdb",
        "/usr/share/GeoIP/GeoLite2-Country.mmdb"
      ]
      candidates.each { |filepath| return filepath if File.exist?(filepath) }
      candidates[0]
    end
  end
end
