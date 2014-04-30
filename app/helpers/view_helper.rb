# -*- encoding : utf-8 -*-
module ViewHelper
  def yes_no(val,yes_text=nil,no_text=nil)
    if val then %Q{<i class="fa fa-check-circle text-success"></i> <span class="text-success">#{yes_text}</span>}.html_safe
    else %Q{<i class="fa fa-times-circle text-danger"></i> <span class="text-error">#{no_text}</span>}.html_safe end
  end
end
