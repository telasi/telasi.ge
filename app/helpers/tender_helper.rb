# -*- encoding : utf-8 -*-
module TenderHelper
  def organization_type_collection
    col = {}
    Tender::Tenderuser::ORG_TYPES.each do |f|
      col[I18n.t("tender.organization_types.#{f}")] = f
    end
    return col
  end

  def tender_user?
  	if current_user
     Tenders::USERS.include?(current_user.email)
    end
  end
end
