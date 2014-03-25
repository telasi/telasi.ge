# -*- encoding : utf-8 -*-
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class MobileValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless record.respond_to?('country_code') and record.country_code != '995'
      unless KA.correct_mobile?(value.to_s)
        record.errors[attribute] << (options[:message] || "is not mobile")
      end
    end
  end
end
