json.success true
json.payments @payments.each do |payment|
	json.paydate 	payment.paydate.strftime('%Y-%m-%d %H:%M:%S'))
    json.amount  	payment.amount
    json.billnumber payment.billnumber
    json.status		payment.status
end