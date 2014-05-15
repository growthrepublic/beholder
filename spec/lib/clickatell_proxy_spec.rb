require "spec_helper"

describe ClickatellProxy do
  describe "#notify" do
    let(:contacts) { ["+48600600600", "+48600600601"] }
    let(:message)  { "some text" }
    let(:api) do
      double.tap { |m| allow(m).to receive(:send_message) }
    end

    subject { described_class.new(api, contacts) }

    it "sends message to each contact" do
      subject.notify(message)

      contacts.each do |contact|
        expect(api).to have_received(:send_message).with(contact, message)
      end
    end
  end
end