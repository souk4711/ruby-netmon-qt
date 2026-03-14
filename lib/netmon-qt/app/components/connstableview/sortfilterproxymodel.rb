class ConnsTableView < RubyQt6::Bando::QWidget
  class SortFilterProxyModel < RubyQt6::Bando::QSortFilterProxyModel
    def initialize(parent)
      super
    end

    def filter_accepts_row(source_row, source_parent)
      {
        1 => parent.processfilter,
        3 => parent.protocolfilter,
        5 => parent.userfilter
      }.each do |column, filter|
        filter_value = filter.current_text
        next if filter_value == "*"

        value = source_model.data(source_model.index(source_row, column)).value
        next if filter_value == value

        return false
      end

      true
    end
  end
end
