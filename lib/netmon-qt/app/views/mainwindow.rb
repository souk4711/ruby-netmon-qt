module NetmonQt
  class MainWindow < RubyQt6::Bando::QMainWindow
    q_object do
    end

    def initialize
      super

      NetmonQt.settings.GET_mainwindow_geometry_and_restore_to(self)
    end

    def close_event(evt)
      NetmonQt.settings.PUT_mainwindow_geometry(self)

      _close_event(evt)
    end
  end
end
