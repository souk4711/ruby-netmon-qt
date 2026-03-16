class ConnsTableView < RubyQt6::Bando::QWidget
  class SortFilterProxyModel < RubyQt6::Bando::QSortFilterProxyModel
    def filter_accepts_row(source_row, source_parent)
      {
        COLUMN_PROCESS_NAME => parent.processfilter,
        COLUMN_PROTOCOL => parent.protocolfilter,
        COLUMN_USER => parent.userfilter
      }.each do |column, filter|
        filter_value = filter.current_text
        next if filter_value == "*"

        value = source_model.data(source_model.index(source_row, column)).value
        next if filter_value == value

        return false
      end

      true
    end

    def less_than(lhs, rhs)
      if lhs.column == COLUMN_LOCAL_ADDRESS || lhs.column == COLUMN_REMOTE_ADDRESS
        lhs_data = IPAddr.new(source_model.data(lhs).value.to_s)
        rhs_data = IPAddr.new(source_model.data(rhs).value.to_s)
        return false if lhs_data.ipv6? && rhs_data.ipv4?
        return true if lhs_data.ipv4? && rhs_data.ipv6?
        super
      elsif lhs.column == COLUMN_LOCAL_PORT || lhs.column == COLUMN_REMOTE_PORT
        lhs_data = source_model.data(lhs).value.to_s.to_i
        rhs_data = source_model.data(rhs).value.to_s.to_i
        lhs_data < rhs_data
      else
        super
      end
    end
  end
end
