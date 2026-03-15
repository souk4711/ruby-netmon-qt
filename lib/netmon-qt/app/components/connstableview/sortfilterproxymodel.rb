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
      if lhs.column == COLUMN_LOCAL_PORT || lhs.column == COLUMN_REMOTE_PORT
        lhs_data = source_model.data(lhs).value
        rhs_data = source_model.data(rhs).value
        lhs_data.to_s.to_i < rhs_data.to_s.to_i
      else
        super
      end
    end
  end
end
