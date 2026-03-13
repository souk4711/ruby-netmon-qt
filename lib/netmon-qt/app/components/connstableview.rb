require_relative "connstableview/store"

class ConnsTableView < RubyQt6::Bando::QWidget
  q_object do
    slot "_autorefresh()"
  end

  def initialize
    super

    initialize_store
    initialize_tableview
    initialize_timer_autorefresh

    mainlayout = QVBoxLayout.new(self)
    mainlayout.add_widget(@tableview)

    @timer.start
  end

  private

  def initialize_store
    @store = Store.new
  end

  def initialize_tableview
    @tableview = QTableView.new
    @tableview.set_model(@store.itemmodel)

    @tableview.horizontal_header.hide_section(0)
    @tableview.vertical_header.set_visible(false)
    @tableview.resize_column_to_contents(1) # Process Name
    @tableview.resize_column_to_contents(6) # Local Address
    @tableview.resize_column_to_contents(8) # Remote Address
  end

  def initialize_timer_autorefresh
    @timer = QTimer.new(self)
    @timer.set_interval(4_000)
    @timer.timeout.connect(self, :_autorefresh)
  end

  def _autorefresh
    @store.refresh
  end
end
