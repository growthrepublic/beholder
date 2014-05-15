require "spec_helper"

shared_examples "check_status" do
  let(:policy) do
    double.tap { |m| allow(m).to receive(:call) }
  end

  let(:finalize) do
    double.tap { |m| allow(m).to receive(:call) }
  end

  before(:each) do
    subject.stub(:request_status) { status }
  end

  it "calls proper policy" do
    subject.check_status(state => policy)
    expect(policy).to have_received(:call)
  end

  it "yields status if block given" do
    subject.check_status(state => policy) { |s| finalize.call(s) }
    expect(finalize).to have_received(:call).with(status)
  end
end

describe App do
  describe "#check_status" do
    subject { create(:app) }

    context "request:success" do
      it_behaves_like "check_status" do
        let(:status) { 200 }
        let(:state)  { :up }
      end
    end

    context "request:redirect" do
      it_behaves_like "check_status" do
        let(:status) { 300 }
        let(:state)  { :up }
      end
    end

    context "request:not_found" do
      it_behaves_like "check_status" do
        let(:status) { 404 }
        let(:state)  { :down }
      end
    end

    context "request:server_error" do
      it_behaves_like "check_status" do
        let(:status) { 500 }
        let(:state)  { :down }
      end
    end
  end

  describe "#monitor_health" do
    context "up" do
      subject { build(:app) }

      before(:each) do
        subject.stub(:check_status) do |*args|
          args.extract_options![:up].call
        end

        subject.stub(:turn_on!)
      end

      it "is being turned on" do
        subject.monitor_health
        expect(subject).to have_received(:turn_on!)
      end
    end

    context "down" do
      subject { build(:app) }

      before(:each) do
        subject.stub(:check_status) do |*args|
          args.extract_options![:down].call
        end

        subject.stub(:turn_off!)
        subject.stub(:notify)
      end

      context "short outage" do
        before(:each) do
          subject.stub(:down_for_minutes?) { false }
        end

        it "is being turned off" do
          subject.monitor_health
          expect(subject).to have_received(:turn_off!)
        end

        it "does not notify" do
          subject.monitor_health
          expect(subject).to_not have_received(:notify)
        end
      end

      context "serious issue" do
        before(:each) do
          subject.stub(:down_for_minutes?) { true }
        end

        it "is being turned off" do
          subject.monitor_health
          expect(subject).to have_received(:turn_off!)
        end

        it "notifies" do
          subject.monitor_health
          expect(subject).to have_received(:notify)
        end
      end
    end
  end

  describe "#turn_off!" do
    context "already down" do
      let(:updated_at) { Time.now - 1.hour }
      subject { create(:crashed_app, updated_at: updated_at) }

      [:aasm_state, :updated_at].each do |attr_name|
        it "does not change :#{attr_name}" do
          expect { subject.turn_off! }.
            to_not change { subject.reload.send(attr_name) }
        end
      end
    end

    context "previously up" do
      let(:updated_at) { Time.now - 1.hour }
      subject { create(:running_app, updated_at: updated_at) }

      it "changes state to down" do
        subject.turn_off!
        expect(subject.aasm_state).to eq "down"
      end

      it "updates :updated_at" do
        expect { subject.turn_off! }.
          to change { subject.reload.updated_at }
      end
    end
  end

  describe "#down_for_minutes?" do
    let(:minutes) { 5 }

    context "down for less than :minutes" do
      subject do
        time_travel_to((minutes-1).minutes.ago) { create(:crashed_app) }
      end

      it "returns true" do
        expect(subject.down_for_minutes?(minutes)).to eq false
      end
    end

    context "down for at least :minutes" do
      subject do
        time_travel_to(minutes.minutes.ago) { create(:crashed_app) }
      end

      it "returns true" do
        expect(subject.down_for_minutes?(minutes)).to eq true
      end
    end

    context "down for more than :minutes+1" do
      subject do
        time_travel_to((minutes+1).minutes.ago) { create(:crashed_app) }
      end

      it "returns false" do
        expect(subject.down_for_minutes?(minutes)).to eq false
      end
    end

    context "up" do
      subject { build(:running_app) }

      it "returns false" do
        expect(subject.down_for_minutes?(minutes)).to eq false
      end
    end
  end

  describe "#request_status" do
    context "responding url" do
      let(:url) { "http://google.com" }
      subject { build(:app, url: url) }

      it "returns success status code" do
        expect(subject.request_status).to be < 400
      end
    end

    context "invalid domain" do
      let(:url) { "http://it-will-never-work-i-am-sure.org" }
      subject { build(:app, url: url) }

      it "returns not found status code" do
        expect(subject.request_status).to eq 404
      end
    end
  end
end