# -*- encoding : utf-8 -*-
class Sys::Signature
  WORKSTEP_URL = 'http://1.1.2.6:57003/WorkstepController.Process.asmx?WSDL'
  WORKSTEP_SIGN = 'http://1.1.2.6:50100/Sign.aspx?WorkstepID='
  WORKSTEP_CONF = '/config/signature/CreateAdhocWorkstep.xml'
  WORKSTEP_CALLBACK = 'http://1.1.2.6/telasi/dms/index.aspx?WorkstepID=##WorkstepId##&amp;'

  def self.send(name, data, id)
    client = Savon.client(wsdl: WORKSTEP_URL)

    doc_response = client.call(:upload_document_v1, :message => { :document => Base64.encode64(data), :fileName => name, :timeToLive => 900 })

    result_string = doc_response.body[:upload_document_v1_response][:upload_document_v1_result]
    xml = Nokogiri::XML(result_string)
    doc_id = xml.css("DocumentId").children.text

    workstep_adhoc = File.read(Dir.pwd + WORKSTEP_CONF)
    workstep_adhoc = workstep_adhoc.gsub(/###callback###/, WORKSTEP_CALLBACK + %q{id=} + id)

    workstep_response = client.call(:create_adhoc_workstep_v2, :message => { :documentId => doc_id, 
                                    :createAdhocWorkstepConfiguration => workstep_adhoc, 
                                    :transactionInformation => "transaction info" } )

    result_string = workstep_response.body[:create_adhoc_workstep_v2_response][:create_adhoc_workstep_v2_result]
    xml = Nokogiri::XML(result_string)
    workstep_id = xml.css("WorkstepId").text

    workstep_id
  end

end
