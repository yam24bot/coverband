# frozen_string_literal: true

Resque.after_fork do |job|
  Coverband.start
end

Resque.before_first_fork do
  Coverband.configuration.background_reporting_enabled = false
  Coverband::Background.stop
  Coverband::Collectors::Coverage.instance.report_coverage(true)
end

module Coverband
  module ResqueWorker
    def perform
      super
    ensure
      Coverband.report_coverage(true)
    end
  end
end

Resque::Job.prepend(Coverband::ResqueWorker)
