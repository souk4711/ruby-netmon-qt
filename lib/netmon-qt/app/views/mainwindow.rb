class MainWindow < RubyQt6::Bando::QMainWindow
  q_object do
  end

  def initialize
    super

    initialize_central_widget
    initialize_statusbar

    set_context_menu_policy(Qt::NoContextMenu)
    NetmonQt.settings.GET_mainwindow_geometry_and_restore_to(self)
  end

  def close_event(evt)
    NetmonQt.settings.PUT_mainwindow_geometry(self)

    _close_event(evt)
  end

  private

  def initialize_central_widget
    @connstableview = ConnsTableView.new

    centralwidget = QWidget.new
    mainlayout = QHBoxLayout.new(centralwidget)
    mainlayout.add_widget(@connstableview)

    set_central_widget(centralwidget)
  end

  def initialize_statusbar
    statusbar = QStatusBar.new
    statusbar.set_contents_margins(12, 0, 12, 0)
    statusbar.add_permanent_widget(@connstableview.statusbar, 1)

    set_status_bar(statusbar)
  end
end
