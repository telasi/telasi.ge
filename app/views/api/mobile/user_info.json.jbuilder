json.success true
json.registrations @registrations.each do |registration|
  customer = Billing::Customer.find(registration.custkey)
  json.id	           registration.id.to_s
  json.custkey         registration.custkey
  json.customer_number customer.accnumb.to_ka
  json.customer_name   customer.custname.to_ka
  json.status   	   registration.status
  json.regionkey	   customer.address.region.regionkey
end
json.logininfo
  json.first_name @user.first_name
  json.last_name  @user.last_name
  json.mobile	  @user.mobile
  json.email	  @user.email
end