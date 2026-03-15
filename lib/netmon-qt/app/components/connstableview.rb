require_relative "connstableview/sortfilterproxymodel"
require_relative "connstableview/store"

class ConnsTableView < RubyQt6::Bando::QWidget
  q_object do
    slot "_autorefresh()"
    slot "_on_autorefreshbtn_changed(Qt::CheckState)"
    slot "_on_filter_changed()"
  end

  attr_reader :processfilter, :protocolfilter, :userfilter

  def initialize
    super

    initialize_store
    initialize_toolbar
    initialize_tableview
    initialize_timer_autorefresh

    mainlayout = QVBoxLayout.new(self)
    mainlayout.add_widget(@toolbar)
    mainlayout.add_widget(@tableview)

    @userfilter.set_current_text(Etc.getpwuid.name)
    @autorefreshbtn.set_check_state(Qt::Checked)
  end

  private

  def initialize_store
    @store = Store.new(self)
  end

  def initialize_toolbar
    @processfilter = QComboBox.new
    @processfilter.set_fixed_width(128)
    @processfilter.add_item("*")
    @store.active_processes.each { |process| @processfilter.add_item(process) }
    @processfilter.current_text_changed.connect(self, :_on_filter_changed)

    @protocolfilter = QComboBox.new
    @protocolfilter.add_item("*")
    @store.active_protocols.each { |protocol| @protocolfilter.add_item(protocol) }
    @protocolfilter.set_fixed_width(128)
    @protocolfilter.current_text_changed.connect(self, :_on_filter_changed)

    @userfilter = QComboBox.new
    @userfilter.set_fixed_width(128)
    @userfilter.add_item("*")
    @store.active_users.each { |user| @userfilter.add_item(user) }
    @userfilter.current_text_changed.connect(self, :_on_filter_changed)

    @autorefreshbtn = QCheckBox.new("Auto Refresh")
    @autorefreshbtn.check_state_changed.connect(self, :_on_autorefreshbtn_changed)

    @toolbar = QWidget.new
    @toolbarlayout = QHBoxLayout.new(@toolbar)
    @toolbarlayout.add_widget(initialize_toolbar_label("Process:"))
    @toolbarlayout.add_widget(@processfilter)
    @toolbarlayout.add_spacing(8)
    @toolbarlayout.add_widget(initialize_toolbar_label("Protocol:"))
    @toolbarlayout.add_widget(@protocolfilter)
    @toolbarlayout.add_spacing(8)
    @toolbarlayout.add_widget(initialize_toolbar_label("User:"))
    @toolbarlayout.add_widget(@userfilter)
    @toolbarlayout.add_stretch
    @toolbarlayout.add_widget(@autorefreshbtn)
  end

  def initialize_toolbar_label(text)
    label = QLabel.new(text)
    label.set_fixed_width(64)
    label
  end

  def initialize_tableview
    @tableview = QTableView.new

    @storeproxymodel = SortFilterProxyModel.new(self)
    @storeproxymodel.set_source_model(@store.itemmodel)
    @tableview.set_model(@storeproxymodel)

    @tableview.horizontal_header.hide_section(0)
    @tableview.vertical_header.set_visible(false)
    @tableview.resize_column_to_contents(COLUMN_PROCESS_NAME)
    @tableview.resize_column_to_contents(COLUMN_LOCAL_ADDRESS)
    @tableview.resize_column_to_contents(COLUMN_REMOTE_ADDRESS)

    @tableview.sort_by_column(COLUMN_PROCESS_NAME, Qt::AscendingOrder)
    @tableview.set_sorting_enabled(true)
  end

  def initialize_timer_autorefresh
    @timer = QTimer.new(self)
    @timer.set_interval(4_000)
    @timer.timeout.connect(self, :_autorefresh)
  end

  def update_filter_additem(filter, items)
    index = filter.count - 1
    items.reverse_each do |item|
      loop do
        case filter.item_text(index) <=> item
        when +0
          break
        when +1
          index -= 1
          next
        when -1
          filter.insert_item(index + 1, item)
          break
        end
      end
    end
  end

  def _autorefresh
    @store.refresh

    update_filter_additem(@processfilter, @store.active_processes)
    update_filter_additem(@userfilter, @store.active_users)
  end

  def _on_autorefreshbtn_changed(state)
    case state
    when Qt::Checked then @timer.start
    when Qt::Unchecked then @timer.stop
    end
  end

  def _on_filter_changed
    @storeproxymodel.invalidate
  end
end
