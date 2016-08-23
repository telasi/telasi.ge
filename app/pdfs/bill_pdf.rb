# -*- encoding : utf-8 -*-
class BillPdf < Prawn::Document

   def initialize(      
                  custkey_v , 
            			payable_balance_v , 
            			trash_balance_v , 
            			current_water_balance_v ,
            			last_bill_date_v,  
            			last_bill_number_v,
                  cut_deadline_v ,
            			accnumb_v,
            			custname_v,
                  t_balance_text_v,
                  t_wbalance_text_v,
                  t_tbalance_text_v ,
                  t_cut_deadline_v,
                  t_bill_header_v,
                  t_print_time_v,
                  t_accnumb_v
                  )

     super(top_margin: 30)

     @cut_deadline_v=cut_deadline_v
     @payable_balance_v=payable_balance_v.to_f
     @trash_balance_v=trash_balance_v.to_f
     @current_water_balance_v=current_water_balance_v.to_f
     #@total_balance=@balance_v+@trash_balance_v+@current_water_balance_v
     @t_balance_text_v = t_balance_text_v  
     @t_wbalance_text_v = t_wbalance_text_v    
     @t_tbalance_text_v = t_tbalance_text_v 

     image "#{Rails.root}/app/assets/images/Telasi_logo.png", :height => 70 , :at => [450, 730]



     font("#{Rails.root}/app/assets/fonts/DejaVuSans.ttf") do
       move_down 20    
       text   t_bill_header_v , size: 20
       move_down 25 
       stroke_horizontal_rule
       move_down 10
       if t_bill_header_v=="ცნობა დავალიანების შესახებ"
          text   "აბონენტი:   " + custname_v, size: 15
       end
       text   t_accnumb_v+ ": " + accnumb_v, size: 15
       
       lineitems
      end

     if @cut_deadline_v > Time.now.strftime('%d/%m/%Y')
	 move_down 20

	  font("#{Rails.root}/app/assets/fonts/DejaVuSans.ttf") do
	    text t_cut_deadline_v + ": "+ @cut_deadline_v.to_s
	  end
     end
     move_down 90
     stroke_horizontal_rule
     move_down 10
       font("#{Rails.root}/app/assets/fonts/DejaVuSans.ttf") do
         text t_print_time_v +": "+ Time.now.strftime('%d/%m/%Y').to_s , size: 10
       end
   end

   def lineitems
     move_down 20
     table line_item_rows do
       columns(1).align= :right
        cells.style(:padding => 3, :border_width => 0.8 , :border_colors => "DDDDDD")
       self.row_colors=["DDDDDD","FFFFFF"]
     end
   end


  def line_item_rows
           [
            [@t_balance_text_v,@payable_balance_v,"GEL"],
            [@t_tbalance_text_v,@trash_balance_v,"GEL"],
            [@t_wbalance_text_v,@current_water_balance_v,"GEL"]
            
           ] 
  end

end
