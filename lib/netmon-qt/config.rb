require_relative "config/initializers/qt6"
require_relative "config/settings"

module NetmonQt
  def self.settings
    @settings ||= Settings.new
  end
end
