class App < ActiveRecord::Base
  NOTIFY_TIMEOUT_IN_MINUTES = 3

  include AASM

  validates :name, length: { within: 2..50 }
  validates :url, format: %r(https?://.+)
  validates :server, length: { within: 2..50 }
  validates :repository_url, format: %r(https?://.+), allow_blank: true
  validates :project_url, format: %r(https?://.+), allow_blank: true

  aasm do
    state :unknown, initial: true
    state :up
    state :down

    event :turn_off do
      transitions to: :down
    end

    event :turn_on do
      transitions to: :up
    end
  end

  def self.monitor_health
    self.all.each(&:monitor_health)
  end

  def monitor_health
    on_up   = -> { turn_on! }
    on_down = -> do
      turn_off!
      notify if down_for_minutes?(NOTIFY_TIMEOUT_IN_MINUTES)
    end

    check_status(up: on_up, down: on_down) do |status|
      logger.info "#{name} is #{aasm_state}! [status: #{status}]"
    end
  end

  def check_status(up: -> {}, down: -> {})
    status = request_status
    policy = status < 400 ? up : down

    policy.call
    yield status if block_given?
  end

  def request_status
    Faraday.head(url).status
  rescue Faraday::ConnectionFailed => ex
    logger.error("#{name} connection failed! #{ex}")
    404
  end

  def notify
    logger.info "sending sms message."
    Rails.configuration.clickatell.notify("#{name} is down!")
  end

  def down_for_minutes?(minutes = 3)
    down? && ((minutes + 1).minutes.ago...minutes.minutes.ago).cover?(updated_at)
  end
end
