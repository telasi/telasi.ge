# -*- encoding : utf-8 -*-
module Payge
  PAY_SERVICES = [ { :ServiceID => 'ENERGY',
                     :ServiceName => 'ელ. ენერგია',
  	                 :Merchant => 'TEST',
                     :Password => 'hn*8SksyoPPheXJ81VDn',
                     :icon => 'fa-bolt'},
  	               { :ServiceID => 'TRASH',
  	                 :ServiceName => 'გასუფთავება', 
  	                 :Merchant => '',
                     :Password => '',
                     :icon => 'fa-trash-o'}, 
  	               { :ServiceID => 'NETWORK',
  	                 :ServiceName => 'ქსელში ჩართვა', 
  	                 :Merchant => '',
                     :Password => '',
                     :icon => 'fa-sign-in'}
  	             ]

  merchant = 'TEST'
  password = 'hn*8SksyoPPheXJ81VDn'

  TESTMODE = 1

  STEP_SEND     = 1
  STEP_RETURNED = 2
  STEP_CALLBACK = 3
  STEP_RESPONSE = 4
end
