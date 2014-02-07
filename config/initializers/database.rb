# -*- encoding : utf-8 -*-

# BS server
Billing::Account.establish_connection          :bs
Billing::AccountTariff.establish_connection    :bs
Billing::Address.establish_connection          :bs
Billing::Custcateg.establish_connection        :bs
Billing::Customer.establish_connection         :bs
Billing::WaterCustomer.establish_connection    :bs
Billing::CustomerRelation.establish_connection :bs
Billing::ItemBill.establish_connection         :bs
Billing::Note.establish_connection             :bs
Billing::Payment.establish_connection          :bs
Billing::Region.establish_connection           :bs
Billing::Street.establish_connection           :bs
Billing::TrashCustomer.establish_connection    :bs
Billing::TrashPayment.establish_connection     :bs
Billing::WaterItem.establish_connection        :bs
Billing::Item.establish_connection             :bs
Billing::Billoperation.establish_connection    :bs
Billing::Person.establish_connection           :bs
Billing::TrashItem.establish_connection        :bs
Billing::Trashoperation.establish_connection   :bs
Billing::NetworkCustomer.establish_connection  :bs
Billing::NetworkItem.establish_connection      :bs
Billing::Paypoint.establish_connection         :bs
Billing::Aviso.establish_connection            :bs
Billing::Tariff.establish_connection           :bs
Billing::TariffStep.establish_connection       :bs

# REPORT server
Billing::WaterPayment.establish_connection  :report_bs

# Site (mysql)
Site::Node.establish_connection :telasi_site
Site::ContentType.establish_connection :telasi_site
Site::Content.establish_connection :telasi_site
Site::ContentThumbnail.establish_connection :telasi_site
Site::File.establish_connection :telasi_site
