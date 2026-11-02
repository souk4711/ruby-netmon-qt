module Ctrlc
  class Handler < RubyQt6::Bando::QObject
    q_object do
      slot "_noop()"
    end

    def initialize
      super($qApp)
    end

    def exec
      ["INT", "TERM"].each do |sig|
        Signal.trap(sig) { |_| QApplication.quit }
      end

      timer = QTimer.new(self)
      timer.timeout.connect(self, :_noop)
      timer.start(1_000)
    end

    private

    def _noop
    end
  end
end
