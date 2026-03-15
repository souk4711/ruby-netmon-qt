require_relative "config"
require_relative "lib"

require_relative "app/components"
require_relative "app/services"
require_relative "app/views"

module NetmonQt
  class Application
    def self.run
      new.exec
    end

    def initialize
      @app = QApplication.new
      @mainwindow = MainWindow.new
    end

    def exec
      Contrib::SigHandler.new(@app)

      @mainwindow.show
      @app.exec
    end
  end
end
