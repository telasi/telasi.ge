json.success true
json.payment
	json.merchant 		@payment.merchant
    json.serviceid	    @payment.serviceid
    json.description	@payment.description
    json.amount			@payment.amount
    json.currency		@payment.currency
    json.clientname		@payment.clientname
    json.ordercode		@payment.ordercode
    json.lng			@payment.lng
    json.check			@payment.check
    json.testmode		@payment.testmode
    json.ispreauth		@payment.ispreauth
    json.postpage		@payment.postpage
    json.successurl		@payment.successurl
    json.cancelurl		@payment.cancelurl
    json.errorurl		@payment.errorurl
    json.callbackurl	@payment.callbackurl
end
