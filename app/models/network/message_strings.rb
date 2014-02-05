# -*- encoding : utf-8 -*-
class Network::MessageStrings
  TEXTS = [
    'თქვენი განცხადება #$number მიღებულია განსახილველად',
    'თქვენი განცხადება #$number მიღებულია წარმოებაში',
    'თქვენი განცხადება #$number დასრულებულია',
    'თქვენი განცხადება #$number უარყოფილია',
  ]

  def self.formatted_texts(application)
    TEXTS.map { |x| x.gsub('$number', application.effective_number.to_s) }
  end
end
