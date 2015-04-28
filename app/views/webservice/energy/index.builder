xml.readings do 
	@energy.each do |item|
		xml.reading do
			xml.date(item.itemdate)
			xml.accnumb(item.accnumb)
			xml.custname(item.custname.tr('ÀÁÂÃÄÅÆÈÉÊËÌÍÏÐÑÒÓÔÖ×ØÙÚÛÜÝÞßàáãä', 'აბგდევზთიკლმნოპჟრსტუფქღყშჩცძწჭხჯჰ'))
			xml.address(item.address.tr('ÀÁÂÃÄÅÆÈÉÊËÌÍÏÐÑÒÓÔÖ×ØÙÚÛÜÝÞßàáãä', 'აბგდევზთიკლმნოპჟრსტუფქღყშჩცძწჭხჯჰ'))
			xml.kwt(item.kwt)
			xml.amount(item.amount)
			xml.subs(item.subs)
			xml.pay(item.pay)
		end	
	end
end