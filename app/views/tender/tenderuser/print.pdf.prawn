def default_font(pdf, size = 9); pdf.change_font('default', size) end

prawn_document(page_size: 'A4', margin: [50, 40]) do |pdf|
  default_font(pdf, 8)

  pdf.move_down 20

  pdf.text %Q{მომხმარებელი}, align: :center, size: 18

  pdf.table [['ელ.ფოსტა',@tenderuser.user.email],
             ['სახელი',@tenderuser.user.first_name],
             ['გვარი',@tenderuser.user.last_name],
             ['მობილური',@tenderuser.user.mobile]],
    column_widths: [nil, 460] do |t|
    t.column(0).style borders: [:bottom], align: :left, size: 10, padding: [20,0,0,0]
    t.column(1).style borders: [:bottom], align: :right, size: 12, padding: [20,0,0,0]
  end

  pdf.move_down 40

  pdf.text %Q{ორგანიზაციის მონაცემები}, align: :center, size: 18

  date = @tenderuser.created_at

  pdf.table [
             ['რეგისტრაციის თარიღი', "#{date.day}\/#{date.month}\/#{date.year}"],
             ['ორგანიზაციის ტიპი',@tenderuser.organization_type_name],
             ['ფიზიკური პირის სახელი და გვარი',@tenderuser.organization_name],
             ['ხელმძღვანელის სახელი და გვარი',@tenderuser.director_name],
             ['ფაქტიური მისამართი',@tenderuser.fact_address],
             ['იურიდიული მისამართი',@tenderuser.legal_address],
             ['საკონტაქტო ტელეფონები',@tenderuser.phones],
             ['სამსახურეობრივი ელ. ფოსტა',@tenderuser.work_email],
             ['პირადი ნომერი',@tenderuser.rs_tin]
            ],
    column_widths: [nil, 400] do |t|
    t.column(0).style borders: [:bottom], align: :left, size: 10, padding: [20,0,0,0]
    t.column(1).style borders: [:bottom], align: :right, size: 12, padding: [20,0,0,0]
  end
end
