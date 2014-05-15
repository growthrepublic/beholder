FactoryGirl.define do
  factory :app do
    name   "Test App"
    url    "http://google.com"
    server "aws"
  end

  factory :crashed_app, parent: :app do
    aasm_state "down"
  end

  factory :running_app, parent: :app do
    aasm_state "up"
  end
end