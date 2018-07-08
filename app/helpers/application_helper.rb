module ApplicationHelper
  def alert_message(klass, message)
    return if message.blank?

    <<-HTML.html_safe
      <div class="alert alert-#{klass} alert-dismissable">
        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
        #{message}
      </div>
    HTML
  end
end
