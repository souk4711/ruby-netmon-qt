class ConnsTableView < RubyQt6::Bando::QWidget
  class StatusBar < RubyQt6::Bando::QWidget
    def initialize(storeproxymodel)
      super()

      @storeproxymodel = storeproxymodel

      initialize_labels

      mainlayout = QHBoxLayout.new(self)
      mainlayout.add_widget(@connections_label)
      mainlayout.add_widget(@established_label)
      mainlayout.add_widget(@listening_label)
      mainlayout.add_widget(@time_wait_label)
      mainlayout.add_stretch
      mainlayout.add_widget(@check_internal_label)
    end

    def refresh
      connections = @storeproxymodel.row_count
      established = 0
      listening = 0
      time_wait = 0

      0.upto(connections - 1) do |row|
        index = @storeproxymodel.index(row, COLUMN_STATE)
        text = @storeproxymodel.data(index).value
        case text
        when Netmon::Connection::STATE_ESTABLISHED then established += 1
        when Netmon::Connection::STATE_LISTEN then listening += 1
        when Netmon::Connection::STATE_TIME_WAIT then time_wait += 1
        end
      end

      @connections_label.set_text("CONNECTIONS: #{connections}")
      @established_label.set_text("ESTABLISHED: #{established}")
      @listening_label.set_text("LISTENING: #{listening}")
      @time_wait_label.set_text("TIME WAIT: #{time_wait}")
    end

    private

    def initialize_labels
      @connections_label = initialize_label("", "#000000")
      @established_label = initialize_label("", COLORS_TCP_STATE[Netmon::Connection::STATE_ESTABLISHED])
      @listening_label = initialize_label("", COLORS_TCP_STATE[Netmon::Connection::STATE_LISTEN])
      @time_wait_label = initialize_label("", COLORS_TCP_STATE[Netmon::Connection::STATE_TIME_WAIT])

      value = NetmonQt.settings.GET_connections_check_interval / 1_000
      @check_internal_label = initialize_check_internal_label("Refresh Internal: #{value} sec", "#000000")
    end

    def initialize_label(text, color)
      label = QLabel.new(text)
      label.set_fixed_width(128)
      label.set_style_sheet("color: #{color};")
      label
    end

    def initialize_check_internal_label(text, color)
      label = QLabel.new(text)
      label.set_fixed_width(192)
      label.set_style_sheet("color: #{color};")
      label.set_alignment(Qt::AlignRight | Qt::AlignVCenter)
      label
    end
  end
end
