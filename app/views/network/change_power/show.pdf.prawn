def default_font(pdf, size = 9); pdf.change_font('default', size) end

prawn_document(page_size: 'A4', margin: [40, 40]) do |pdf|
  default_font pdf
  pdf.text %Q{სს "თელასის" ტექნიკურ დირექტორს\nბატონ ვ. ქინქლაძეს}, align: :right
  pdf.text %Q{Техническому директору АО "Теласи"\nг-ну В. Кинкладзе}, align: :right
  pdf.move_down 20
  pdf.table [['', "გ ა ნ ც ხ ა დ ე ბ ა\nЗ А Я В Л Е Н И Е", "№#{@application.number}"]], column_widths: [200, 150, 150] do
    row(0).style borders: [], align: :center, size: 14
    column(2).style valign: :center, size: 10
  end
  # pdf.text %Q{გ ა ნ ც ხ ა დ ე ბ ა\nЗ А Я В Л Е Н И Е}, align: :center, size: 14
  pdf.move_down 5
  pdf.text %Q{მომხმარებლის ს/ს "თელასის" გამანაწილებელ ქსელზე მიერთება}, align: :center
  pdf.text %Q{Присоединение эл. потребителя к распределительной сети АО "Теласи"}, align: :center
  pdf.move_down 5
  full_w = pdf.bounds.width
  pdf.table [['თარიღი / Дата', @application.send_date.strftime('%d/%m/%Y')]], column_widths: [full_w - 100, 100] do
    column(0).style borders: [], align: :right
    column(1).style borders: [:bottom], align: :center
  end
  pdf.move_down 5
  pdf.table [
      ["1. ორგანიზაციის ან ფიზიკური პირის დასახელება:\nНазвание организации или физического лица:", @application.rs_name],
      ["2. გამრიცხველიანების მისამართი:\nАдресс проведения работ:", "#{@application.address_code} -- #{@application.work_address || @application.address}"],
      ["ტელეფონი / телефон", KA.format_mobile(@application.mobile)],
      [
        "3. აბონენტი № / Абонент №", ("#{@application.customer.accnumb.to_ka} -- #{@application.customer.custname.to_ka}" if @application.customer)
      ],
      ["3.1. არსებული სიმძლავრე:\nТекущее мощность:", "#{@application.old_power} კვტ.სთ"],
      ["3.2. არსებული ძაბვა:\nТекущее напряжение:", "#{@application.old_voltage} #{@application.old_unit}"],
      ["4. მოთხოვნილი სიმძლავრე:\nТребуемая мощность:", "#{@application.power} კვტ.სთ."],
      ["5. ძაბვის სიმძლავრე და გვარობა:\nВеличина и вид напряжения:", "#{@application.voltage} #{@application.unit}"]
    ], column_widths: [220, full_w - 220] do
    column(0).style borders: [], size: 8
    column(1).style borders: [:bottom], valign: :center
  end
  pdf.move_down 5
  pdf.text %Q{6. ორგანიზაციის ან ფიზიკური პირის დასტური პროექტის შესრულებაზე ს/ს "თელასის" მიერ:\nСогласие организации или физического лица на выполнение проекта сотрудниками АО "Теласи":}
  pdf.table [
      ['', (@application.work_by_telasi ? '☒' : '☐'), '', (@application.work_by_telasi ? '☐' : '☒')],
      ['', 'დიახ/да', '', 'არა/нет']
    ], column_widths: [(full_w - 200)/2, 50, 100, 50] do
    row(0..1).style borders: [], align: :center, padding: [2, 0]
    row(1).column(1).style borders: [:top]
    row(1).column(3).style borders: [:top]
    row(1).style size: 6, padding: 0
  end
  pdf.move_down 10
  pdf.text 'განცხადებას თან ერთვის / к заявлению прилагаются'
  pdf.table [
    ['1. ობიექტის საკუთრების დამადასტურებელი საბუთი / Документ, подтверждающий принадлежность объекта'],
    ['2. სიტუაციური გეგმა (საჭიროების შემთხვევაში) / Ситуационный план (по необходимости)'],
    ['3. განმცხადებლის პირადობის დამადასტურებელი მოწმობის ასლი / Копия удостоверения личности заявителя'],
  ] do
    column(0).style borders: []
  end
  pdf.move_down 10
  pdf.text 'ობიექტის რეკვიზიტები:'
  pdf.table [
    ['1. იურიდიული მისამართი:', @application.address],
    ['2. საიდენტიფიკაციო კოდი:', @application.rs_tin],
    ['3. მომსახურე ბანკის დასახელება და კოდი:', "#{@application.bank_code} #{@application.bank_name}"],
    ['4. ანგარიშის ნომერი:', "#{@application.bank_account}"],
  ], column_widths: [ 220, full_w - 220 ] do
    column(0).style borders: []
    column(1).style borders: [:bottom]
  end
  pdf.table [
    ['5. ორგანიზაციის ან ფიზიკური პირის დასტური საგადასახადო ანგარიშ-ფაქტურის წარდგენაზე / Согласие организации или физического лица на представление налоговой счет-фактуры:'],
  ] do
    column(0).style borders: []
  end
  pdf.table [
      ['', (@application.need_factura ? '☒' : '☐'), '', (@application.need_factura ? '☐' : '☒')],
      ['', 'დიახ/да', '', 'არა/нет']
    ], column_widths: [(full_w - 200)/2, 50, 100, 50] do
    row(0..1).style borders: [], align: :center, padding: [2, 0]
    row(1).column(1).style borders: [:top]
    row(1).column(3).style borders: [:top]
    row(1).style size: 6, padding: 0
  end
  pdf.move_down 20
  pdf.table [['განმცხადებელი / Заявитель:', ''], ['', 'ხელმოწერა / Подпись']], column_widths: [ 200, full_w - 200 ] do
    column(0..1).style borders: []
    row(1).column(1).style borders: [:top], size: 6, padding: 0, align: :center
  end
end
