class AhaServices::GoogleHangoutsChat < AhaService
  caption "Send customized activity from Aha! into group chat"
  category "Communication"
  
  string :google_hangouts_chat_webhook_url,
    description: "The webhook that you copied from the room"
  install_button
  
  audit_filter
  
  def receive_installed
    send_message(text: "Aha! integration installed successfully. Make sure you enable the integration!")
  end
  
  def receive_audit
    audit = payload.audit
    return unless audit.interesting
    
    user = if audit.user
        audit.user.name
      else
        "Aha!"
      end
    
    description = "<b>#{user}</b> #{audit.description}"
      
    title_section = {
      widgets: [ { textParagraph: { text: description } } ]
    }

    kvs = audit.changes.map do |change|
      frag = Nokogiri::HTML.fragment(change["value"].to_s)
      frag.css('.deleted').each { |el| el.name= "font"; el.set_attribute("color" , "#9d261d") } # modifies frag in place
      frag.css('.inserted').each { |el| el.name= "font"; el.set_attribute("color" , "#46a546") } # modifies frag in place
      { keyValue: { topLabel: change["field_name"], content: frag.to_html, contentMultiline: "true" } }
    end

    update_section = {
      widgets: kvs
    }

    link_section = {
      widgets: [
        {
          buttons: [
            {
              textButton: {
                text: "VIEW IN AHA!",
                onClick: {
                  openLink: { url: audit.auditable_url }
                }
              }
            }
          ]
        }
      ]
    }

    sections = kvs.empty? ? [title_section, link_section] : [title_section, update_section, link_section]
    message = { cards: [ { sections: sections } ] }
    send_message(message)
  end
    
  
protected

  def is_wide_field(field_name)
    !["Description", "Theme", "Body"].include?(field_name)
  end

  def url
    data.google_hangouts_chat_webhook_url
  end

  def send_message(message)
    raise AhaService::RemoteError, "Integration has not been configured" unless url

    http.headers['Content-Type'] = 'application/json'
    response = http_post(url, message.to_json)
    if [200, 201, 204].include?(response.status)
      return
    elsif response.status == 404
      raise AhaService::RemoteError, "URL is not recognized"
    else
      error = Hashie::Mash.new(JSON.parse(response.body))
      
      raise AhaService::RemoteError, "Unhandled error: STATUS=#{response.status} BODY=#{error.message}"
    end
  end
  
end
