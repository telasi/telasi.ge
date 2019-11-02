# -*- encoding : utf-8 -*-
class Sys::PdfTemplate

    def self.send_to_client(template, output_name, params)
    	content = render_to_content(template, params)
    	send_data(content, :filename => output_name, :type => 'application/pdf', :disposition => 'inline')	
    end

    def self.render_to_content(template, params)
    	output_file = "#{Rails.root}/tmp/#{SecureRandom.uuid}.pdf"
    	render_to_file(template, output_file, params)
	   	content = ''
	    File.open(output_file, 'rb') do |f|
	      content = f.read
	    end
	    File.delete(output_file)
	    return content
    end

    def self.render_to_file(template, output_file, params)
    	pdftk = PdfForms.new('pdftk', :data_format => 'XFdf')
    	pdftk.fill_form template, output_file, params, :flatten => true, :drop_xfa => true
    end

end