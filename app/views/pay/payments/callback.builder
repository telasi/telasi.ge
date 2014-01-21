xml.result do
	xml.resultcode(@payment.resultcode)
	xml.resultdesc(@payment.resultdesc)
	xml.check(@payment.check_response)
	xml.data(@payment.data)
end