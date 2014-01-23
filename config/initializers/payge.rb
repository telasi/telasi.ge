# -*- encoding : utf-8 -*-
module Payge
  PAY_SERVICES = [ { :ServiceID => 'ENERGY',
                     :ServiceName => 'ელ. ენერგია',
  	                 :Merchant => 'TEST',
                     :Password => 'hn*8SksyoPPheXJ81VDn',
                     :field => 'accnumb',
                     :icon => 'fa-bolt'},
  	               { :ServiceID => 'TRASH',
  	                 :ServiceName => 'დასუფთავება', 
  	                 :Merchant => '',
                     :Password => '',
                     :field => 'accnumb',
                     :icon => 'fa-trash-o'}, 
  	               { :ServiceID => 'NETWORK',
  	                 :ServiceName => 'ქსელში ჩართვა', 
  	                 :Merchant => '',
                     :Password => '',
                     :field => 'rs_tin',
                     :icon => 'fa-sign-in'}
  	             ]

  URLS = { :success  => 'http://my.telasi.ge/pay/payment/success?',
           :cancel   => 'http://my.telasi.ge/pay/payment/cancel?',
           :error    => 'http://my.telasi.ge/pay/payment/error?',
           :callback => 'http://my.telasi.ge/pay/payment/callback?'

         }

  BILLING_CONSTANTS = {
                        :billoperkey => 35,
                        :paytpkey    => 1,
                        :ppointkey   => 265,
                        :perskey     => 1,
                        :status      => 1
                      }

  merchant = 'TEST'
  password = 'hn*8SksyoPPheXJ81VDn'

  TESTMODE = 1

  STEP_SEND     = 1
  STEP_RETURNED = 2
  STEP_CALLBACK = 3
  STEP_RESPONSE = 4
end
