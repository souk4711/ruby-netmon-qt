class ConnsTableView < RubyQt6::Bando::QWidget
  class SortFilterProxyModel < RubyQt6::Bando::QSortFilterProxyModel
    def filter_accepts_row(source_row, source_parent)
      {
        COLUMN_PROCESS_NAME => parent.processfilter,
        COLUMN_PROTOCOL => parent.protocolfilter,
        COLUMN_STATE => parent.statefilter,
        COLUMN_USER => parent.userfilter
      }.each do |column, filter|
        filter_value = filter.current_text
        next if filter_value == "*"

        value = source_model.data(source_model.index(source_row, column)).value
        next if filter_value == value
        next if column == COLUMN_PROTOCOL && value.starts_with(filter_value)

        return false
      end

      true
    end

    def less_than(lhs, rhs)
      case lhs.column
      when COLUMN_PROCESS_NAME
        less_than_process_name(lhs, rhs)
      when COLUMN_LOCAL_ADDRESS, COLUMN_REMOTE_ADDRESS
        less_than_address(lhs, rhs)
      when COLUMN_PROCESS_ID, COLUMN_LOCAL_PORT, COLUMN_REMOTE_PORT
        less_than_numeric(lhs, rhs)
      when COLUMN_SINCE
        less_than_since(lhs, rhs)
      else
        super
      end
    end

    private

    def less_than_process_name(lhs, rhs)
      lhs_data = source_model.data(lhs).value
      rhs_data = source_model.data(rhs).value
      case lhs_data <=> rhs_data
      when +0
        lhs = source_model.index(lhs.row, COLUMN_STATE)
        rhs = source_model.index(rhs.row, COLUMN_STATE)
        less_than(lhs, rhs)
      when +1
        false
      when -1
        true
      end
    end

    def less_than_address(lhs, rhs)
      lhs_data = IPAddr.new(source_model.data(lhs).value.to_s)
      rhs_data = IPAddr.new(source_model.data(rhs).value.to_s)
      return false if lhs_data.ipv6? && rhs_data.ipv4?
      return true if lhs_data.ipv4? && rhs_data.ipv6?
      lhs_data < rhs_data
    end

    def less_than_numeric(lhs, rhs)
      lhs_data = source_model.data(lhs).value.to_s.to_i
      rhs_data = source_model.data(rhs).value.to_s.to_i
      lhs_data < rhs_data
    end

    def less_than_since(lhs, rhs)
      lhs_data, rhs_data = [lhs, rhs].map do |index|
        s = source_model.data(index).value.to_s
        next 0 if s.empty?
        s.scan(/\d+\w/).map do |value_unit|
          value, unit = value_unit[..-1].to_i, value_unit[-1]
          case unit
          when "d" then value * 24 * 60 * 60
          when "h" then value * 60 * 60
          when "m" then value * 60
          when "s" then value
          end
        end.reduce(:+)
      end
      lhs_data < rhs_data
    end
  end
end
