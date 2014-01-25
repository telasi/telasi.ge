# -*- encoding : utf-8 -*-
module PaymentsHelper

    def servicetext(serviceid)
       return t("services.#{serviceid.downcase}")
    end

    def merchant_collection
    	Hash[Payge::PAY_SERVICES.map { |x| [x[:ServiceName],x[:ServiceID]] } ]
    end

    def can_pay?
    	if current_user
    		Payge::USERS.include?(current_user.email)
    	end
    end
end
