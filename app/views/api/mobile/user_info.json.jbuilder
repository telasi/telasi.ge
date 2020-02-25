json.success true
json.registrations @registrations.each do |registration|
  customer = Billing::Customer.find(registration.custkey)
  json.custkey         registration.custkey
  json.customer_number customer.accnumb.to_ka
  json.customer_name   customer.custname.to_ka
  json.status   	   customer.status
end