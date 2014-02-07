# -*- encoding : utf-8 -*-
module I18n
  def site_locale
    case I18n.locale.to_s
    when 'ka' then 'ge'
    else I18n.locale
    end
  end

  module_function :site_locale
end
