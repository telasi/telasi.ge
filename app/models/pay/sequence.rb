# -*- encoding : utf-8 -*-
class Pay::Sequence
  include Mongoid::Document

  field :sequence,        type: Integer

end
