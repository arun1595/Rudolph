module ApplicationHelper

  def hide_breadcrumbs?
    controller_name == 'registrations' || action_name == 'who' || action_name == 'index'
  end

  def hide_footer?
    (controller_name == 'index' && action_name == 'index') || action_name == 'who'
  end

  def is_url?(string)
    string.include?('http://') || string.include?('https://')
  end

  def cut_text(text, size)
    text.size <= size ? text : "#{text[0..size-1]}..."
  end
end
