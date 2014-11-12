# -*- encoding : utf-8 -*-
module Network
  PAYPOINTS = [ 693, 717, 718, 719, 720, 873 ]

  # sdweb

  SDWEB_DMSID = 'de.softpro.sdweb.plugins.impl.FileDms'
  SDWEB_CMD  = 'name=sig1|page=3|type=formfield|subtype=signature|bottom=450|left=200|width=250|height=50'

  SDWEB_BASE_URL   = 'http://1.1.2.60:8080/sdweb'
  SDWEB_LOAD_URL   = "#{SDWEB_BASE_URL}/load/bydms"
  SDWEB_UPLOAD_URL = "#{SDWEB_BASE_URL}/load/byupload"
  SDWEB_GUI_URL    = "#{SDWEB_BASE_URL}/signdoc/showgui"  
end
