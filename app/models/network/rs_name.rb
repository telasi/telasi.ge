# -*- encoding : utf-8 -*-
module Network::RsName
  def validate_rs_name
    if self.rs_tin.present? and (self.rs_tin_changed? or self.rs_name.blank?)
      unless self.rs_foreigner
        self.rs_name = RS.get_name_from_tin(RS::TELASI_SU.merge(tin: self.rs_tin)) #if self.rs_name.blank?
        if self.rs_name.blank?
          self.errors.add(:rs_tin, I18n.t('models.network_new_customer_application.errors.tin_illegal'))
        end
      end
    end
  end
end
