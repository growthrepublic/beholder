class ClickatellProxy < Struct.new(:api, :contacts)
  def notify(message)
    contacts.each do |contact|
      notify_contact(contact, message)
    end
  end

  private

  def notify_contact(contact, message)
    api.send_message(contact, message)
  rescue Clickatell::API::Error => e
    logger.error(e)
  end
end