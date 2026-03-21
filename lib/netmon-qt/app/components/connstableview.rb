require_relative "connstableview/sortfilterproxymodel"
require_relative "connstableview/statusbar"
require_relative "connstableview/store"

class ConnsTableView < RubyQt6::Bando::QWidget
  QSS_BUTTON_AUTOREFRESH = "
    QPushButton {
      background: #EFF0F1;
      color: #7F8C8D;
      border: 1px solid #BCBEBF;
      border-bottom: 3px solid #B0B0B0;
      border-radius: 3px;
      padding: 6px;
      font-weight: bold;
    }
    QPushButton:checked {
      background: #FFFFFF;
      color: #31363B;
    }
  "

  q_object do
    slot "_on_filter_changed()"
    slot "_on_autorefreshbtn_toggled(bool)"
    slot "_on_autorefresh_timer_timeout()"
    slot "_on_tableview_custom_context_menu_requested(QPoint)"
  end

  attr_reader :processfilter, :protocolfilter, :statefilter, :userfilter
  attr_reader :statusbar

  def initialize
    super

    @lastindex = nil

    initialize_store
    initialize_actions
    initialize_toolbar
    initialize_tableview
    initialize_statusbar
    initialize_timer_autorefresh

    mainlayout = QVBoxLayout.new(self)
    mainlayout.add_widget(@toolbar)
    mainlayout.add_widget(@tableview)

    @userfilter.set_current_text(Etc.getpwuid.name)
    @autorefreshbtn.set_checked(true)
  end

  private

  def initialize_store
    @store = Store.new(self)
  end

  def initialize_actions
    @endprocess_action = initialize_actions_act(QIcon::ThemeIcon::ApplicationExit, "End Process")
    @whois_action = initialize_actions_act(QIcon::ThemeIcon::EditFind, "")
    @copy_action = initialize_actions_act(QIcon::ThemeIcon::EditCopy, "")
  end

  def initialize_actions_act(icon, text)
    QAction.new(QIcon.from_theme(icon), text, self)
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

    @statefilter = QComboBox.new
    @statefilter.add_item("*")
    @store.active_states.each { |state| @statefilter.add_item(state) }
    @statefilter.set_fixed_width(128)
    @statefilter.current_text_changed.connect(self, :_on_filter_changed)

    @userfilter = QComboBox.new
    @userfilter.set_fixed_width(128)
    @userfilter.add_item("*")
    @store.active_users.each { |user| @userfilter.add_item(user) }
    @userfilter.current_text_changed.connect(self, :_on_filter_changed)

    @autorefreshbtn = QPushButton.new("")
    @autorefreshbtn.set_fixed_width(192)
    @autorefreshbtn.set_style_sheet(QSS_BUTTON_AUTOREFRESH)
    @autorefreshbtn.set_checkable(true)
    @autorefreshbtn.toggled.connect(self, :_on_autorefreshbtn_toggled)

    @toolbar = QWidget.new
    @toolbarlayout = QHBoxLayout.new(@toolbar)
    @toolbarlayout.add_widget(initialize_toolbar_label("Process:"))
    @toolbarlayout.add_widget(@processfilter)
    @toolbarlayout.add_spacing(8)
    @toolbarlayout.add_widget(initialize_toolbar_label("Protocol:"))
    @toolbarlayout.add_widget(@protocolfilter)
    @toolbarlayout.add_spacing(8)
    @toolbarlayout.add_widget(initialize_toolbar_label("State:"))
    @toolbarlayout.add_widget(@statefilter)
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
    @tableview.set_selection_behavior(QAbstractItemView::SelectRows)
    @tableview.set_selection_mode(QAbstractItemView::SingleSelection)
    @tableview.set_context_menu_policy(Qt::ContextMenuPolicy::CustomContextMenu)
    @tableview.custom_context_menu_requested.connect(self, :_on_tableview_custom_context_menu_requested)

    @storeproxymodel = SortFilterProxyModel.new(self)
    @storeproxymodel.set_source_model(@store.itemmodel)
    @tableview.set_model(@storeproxymodel)

    @tableview.horizontal_header.hide_section(0)
    @tableview.vertical_header.set_visible(false)
    @tableview.set_column_width(COLUMN_PROCESS_NAME, 128)
    @tableview.set_column_width(COLUMN_LOCAL_ADDRESS, 192)
    @tableview.set_column_width(COLUMN_REMOTE_ADDRESS, 192)
    @tableview.set_column_width(COLUMN_SINCE, 128)

    @tableview.sort_by_column(COLUMN_PROCESS_NAME, Qt::AscendingOrder)
    @tableview.set_sorting_enabled(true)
  end

  def initialize_statusbar
    @statusbar = StatusBar.new(@storeproxymodel)
  end

  def initialize_timer_autorefresh
    @timer = QTimer.new(self)
    @timer.set_interval(NetmonQt.settings.GET_connections_check_interval)
    @timer.timeout.connect(self, :_on_autorefresh_timer_timeout)
  end

  def update_filter_additem(filter, items)
    index = filter.count - 1
    items.reverse_each do |item|
      loop do
        case filter.item_text(index) <=> item
        when +0 then break
        when +1 then (index -= 1) || next
        when -1 then filter.insert_item(index + 1, item) || break
        end
      end
    end
  end

  def _on_filter_changed
    @storeproxymodel.invalidate
    @statusbar.refresh
  end

  def _on_autorefreshbtn_toggled(checked)
    if checked
      @autorefreshbtn.set_text("Auto Refresh:  ON")
      @timer.start
      _on_autorefresh_timer_timeout
    else
      @autorefreshbtn.set_text("Auto Refresh: OFF")
      @timer.stop
    end
  end

  def _on_autorefresh_timer_timeout
    @store.refresh

    update_filter_additem(@processfilter, @store.active_processes)
    update_filter_additem(@userfilter, @store.active_users)
    _on_filter_changed
  end

  def _on_tableview_custom_context_menu_requested(position)
    @lastindex = @tableview.index_at(position)
    return unless @lastindex.valid?

    menu = QMenu.new("", self)
    menu.set_attribute(Qt::WA_DeleteOnClose)

    pid = @lastindex.sibling_at_column(COLUMN_PROCESS_ID).data.value.to_s
    remote_address = @lastindex.sibling_at_column(COLUMN_REMOTE_ADDRESS).data.value.to_s
    remote_address = remote_address.include?(".") ? remote_address : "#{remote_address[0, 12]}..."
    text = @lastindex.data.value.to_s

    @endprocess_action.set_enabled(pid.to_i.nonzero?)
    @whois_action.set_text("Whois #{remote_address} - via IPinfo")
    @copy_action.set_text("Copy \"#{text}\"")

    menu.add_action(@endprocess_action)
    menu.add_separator
    menu.add_action(@whois_action)
    menu.add_action(@copy_action)

    case menu.exec(@tableview.viewport.map_to_global(position))
    when @endprocess_action then _on_endprocess_action_triggered(pid)
    when @whois_action then _on_whois_action_triggered(remote_address)
    when @copy_action then _on_copy_action_triggered(text)
    end
  end

  def _on_endprocess_action_triggered(pid)
    QProcess.execute("kill", QStringList.new << "-9" << pid)
  end

  def _on_whois_action_triggered(remote_address)
    url = QUrl.new("https://ipinfo.io/#{remote_address}")
    QDesktopServices.open_url(url)
  end

  def _on_copy_action_triggered(text)
    QApplication.clipboard.set_text(text)
  end
end
