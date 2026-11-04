class MainWindow < RubyQt6::Bando::QMainWindow
  private

  def initialize_ui
    initialize_central_widget
    initialize_statusbar

    set_context_menu_policy(Qt::NoContextMenu)
  end

  def initialize_central_widget
    @connstableview = MainWindowConnsTableView.new

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
