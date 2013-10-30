# coding: utf-8
module DeviseHelper
  def devise_error_messages!
    flash_alerts = []
    if !flash.empty?
      flash_alerts.push(flash[:error]) if flash[:error]
      flash_alerts.push(flash[:alert]) if flash[:alert]
      flash_alerts.push(flash[:notice]) if flash[:notice]
      error_key = 'devise.failure.invalid'
    end

    return "" if resource.errors.empty? && flash_alerts.empty?
    if flash_alerts.present? 
      messages = flash_alerts.map { |msg| content_tag(:p, msg) }.join
    else
      messages = resource.errors.full_messages.map { |msg| content_tag(:p, msg) }.join
    end

    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase) rescue nil
    html = <<-HTML 
      <div class="n_error">
        <!-- <div>#{sentence}</div> -->
        #{messages}
      </div>
    HTML
    html.html_safe
  end
end