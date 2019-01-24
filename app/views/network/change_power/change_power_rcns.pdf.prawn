@table_height = 18

def default_font(pdf, size = 9); pdf.change_font('default', size) end

def month_name(month)
  case month
  when 1 then 'იანვარი'
  when 2 then 'თებერვალი'
  when 3 then 'მარტი'
  when 4 then 'აპრილი'
  when 5 then 'მაისი'
  when 6 then 'ივნისი'
  when 7 then 'ივლისი'
  when 8 then 'აგვისტო'
  when 9 then 'სექტემბერი'
  when 10 then 'ოქტომბერი'
  when 11 then 'ნოემბერი'
  when 12 then 'დეკემბერი'
  end
end

prawn_document(page_size: 'A4', margin: [30, 30]) do |pdf|
  default_font(pdf, 8)
  pdf.text %Q{ დანართი 3
    "დამტკიცებულია" }, align: :right, size: 10
  pdf.text %Q{ საქართველოს ენერგეტიკისა და წყალმომარაგების
    მარეგულირებელი ეროვნული კომისიის 
    2011 წლის 22 ნოემბრის №30/1 გადაწყვეტილებით }, align: :right
  pdf.move_down 10
  date = @application.created_at
  pdf.table [[{content: 'რეგ. №', height: 20 }, {content: @application.number, height: 20 }, {content: 'თარიღი:', height: @table_height }, {content: "#{date.day} #{month_name(date.month)} #{date.year}", height: 20 }],[{content: '(ივსება განაწილების ლიცენზიატის მიერ)', colspan: 4, height: 20 }]], column_widths: [50, 150, 60, 150] do |t|
    t.column(0).style borders: [], size: 10
    t.column(1).style borders: [:bottom], align: :center, size: 10
    t.column(2).style borders: [], size: 10
    t.column(3).style borders: [:bottom], align: :center, size: 10
    t.row(1).style borders: [], align: :center, size: 6
  end
  pdf.move_down 10
  pdf.text 'გამანაწილებელ ქსელზე მიკროსიმძლავრის ელექტროსადგურის მიერთების მოთხოვნის შესახებ განაცხადი', align: :center, size: 16
  pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
    pdf.move_down 3
    pdf.text 'განმცხადებლის საყურადღებოდ!', align: :center, size: 10
    pdf.move_down 5
    pdf.indent 5,5 do
      pdf.text %Q{ განაწილების ლიცენზიატი ვალდებულია, დაუყოვნებლივ დაარეგისტრიროს განმცხადებლის მიერ წარდგენილი ნებისმიერი სახის წერილობითი განცხადება (განაცხადი) და დაუყოვნებლივ გასცეს განაცხადის რეგისტრაციის ნომერი, რეგისტრაციის თარიღის მითითებით.
      „გამანაწილებელ ქსელზე მიკროსიმძლავრის ელექტროსადგურის მიერთების მოთხოვნის შესახებ“ განაცხადი დამტკიცებულია კომისიის 2011 წლის 22 ნოემბრის #30/1 გადაწყვეტილებით, განმცხადებელი არ არის ვალდებული, მიაწოდოს განაწილების ლიცენზიატს რაიმე დამატებითი ინფორმაცია ან დოკუმენტი გარდა იმისა, რაც გათვალისწინებულია კომისიის მიერ დამტკიცებული განაცხადის ფორმით.
      განმცხადებელი უფლებამოსილია, მისი უფლებების დარღვევის შემთხვევაში, მიმართოს მომხმარებელთა ინტერესების საზოგადოებრივ დამცველს (ქ. თბილისი, ა. მიცკევიჩის ქუჩა #19, (+995 322) 2 42 01 90)“ }, align: :justify, size: 10, indent_paragraphs: 20, position: :center
  end
  pdf.move_down 3
  pdf.stroke_bounds
end
  pdf.move_down 10
  default_font(pdf)
  date = @application.created_at
  pdf.table [['განაცხადის შევსების თარიღი:', "#{date.day} #{month_name(date.month)} #{date.year}"]], column_widths: [nil, 150] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom], align: :center
  end
  pdf.move_down 30
  pdf.text 'I. ზოგადი ინფორმაცია ', size: 12
  pdf.move_down 10
  pdf.table [[{ content: '1. ელექტროენერგიის განაწილების ლიცენზიანტი:', height: @table_height }, { content: 'სს თელასი', height: @table_height }]], column_widths: [230, 250] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 15
  pdf.table [[{ content: '2. მიერთების მსურველი (განმცხადებლი):', height: @table_height }, { content: @application.rs_name, height: @table_height }]], column_widths: [200, 280] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 7
  pdf.text '(სახელი, გვარი ან იურიდიული პირის შემთხვევაში მისი სახელი (სახელწოდება), ან სხვა პირის შემთხვევაში მისი სახელწოდება)', size: 6, align: :center, height: 7
  pdf.move_down 7
  pdf.table [[ {content: '3. პირადი ნომერი/საიდენტიფიკაციო კოდი:', height: @table_height }, { content: @application.rs_tin, height: @table_height }]],
    column_widths: [200, 280] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 15
  pdf.table [[{content: '4. აბონენტის №', height: @table_height}, {content: ("#{@application.customer.accnumb.to_ka} -- #{@application.customer.custname.to_ka}" if @application.customer), height: @table_height }]], column_widths: [nil, 205] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 15
  pdf.table [[{content: '5. მიერთების მსურველის (განმცხადებლის) საკონტაქტო ინფორმაცია:', height: @table_height}]] do |t|
    t.column(0).style borders: []
  end
  pdf.move_down 15
  pdf.text 'მისამართი:', indent_paragraphs: 18
  pdf.table [[' ', {content: "#{@application.address}", height: @table_height}]], column_widths: [20,500] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.table [[' ', {content: 'მობ. ტელ:', height: @table_height }, {content: @application.mobile, height: @table_height }, {content:  'ელ.ფოსტა:', height: @table_height }, {content: @application.email, height: @table_height }]],
    column_widths: [15,60,100,70,230] do |t|
    t.column(0..3).style borders: []
    t.column(2).style borders: [:bottom]
    t.column(4).style borders: [:bottom]
  end
  pdf.move_down 15
  pdf.table [[{content: '6. მიერთების მსურველის (განმცხადებლის) საბანკო რეკვიზიტები:', height: @table_height}]], column_widths: [nil, 205] do |t|
    t.column(0).style borders: []
  end
  pdf.table [['', {content: "#{@application.bank_code}, #{@application.bank_name}, #{@application.bank_account}", height: @table_height }]], column_widths: [nil, 505] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 15
  pdf.table [[{content: '7. ადგილი (მისამართი) სადაც ხდება ელექტრომომარაგება და უნდა მოხდეს მიკროსიმძლავრის ელექტროსადგურის მიერთება: ', height: @table_height}]], column_widths: [505] do |t|
    t.column(0).style borders: []
  end
  pdf.table [[{content: 'ელექტროსადგურის მიერთება: ', height: @table_height}]], column_widths: [505] do |t|
    t.column(0).style borders: []
  end
  pdf.table [['', {content: "#{@application.work_address}", height: @table_height }]], column_widths: [15, 505] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 15
  pdf.table [['8. ძაბვის საფეხური (ვოლტი): _________________']] do |t|
    t.column(0..1).style borders: []
  end
  pdf.table [[" ", "#{(@application.old_voltage == '220' ? '☒' : '□')} 220ვ;  #{(@application.old_voltage == '380' ? '☒' : '□')} 380ვ;  #{(@application.old_voltage == '6/10' ? '☒' : '□')} 6/10კვ;"]] do |t|
    t.column(0..3).style borders: []
  end
  pdf.move_down 15
  pdf.text '9. მომხმარებლის გამანაწილებელ ქსელთან არსებული მისაერთებელი სიმძლავრე:', indent_paragraphs: 4
  pdf.table [[' ', '                                   ']] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 15
  pdf.text '10. განაწილების ლიცენზიატის მიერ შეტყობინების გაგზავნის ფორმა:', indent_paragraphs: 4
  pdf.move_down 3
  pdf.text '□ წერილობითი ან ☒ ელექტრონული.', indent_paragraphs: 20
  pdf.move_down 15
  pdf.text '11. გესაჭიროებათ საგადასახადო ანგარიშ-ფაქრუტა?', indent_paragraphs: 4
  pdf.table [[" ", "#{(@application.need_factura ? '☒ ' : '☐ ')} დიახ #{(@application.need_factura ? '☐ ' : '☒ ')} არა"]] do |t|
    t.column(0..3).style borders: []
  end
  pdf.move_down 20
  pdf.text 'II. ინფორმაცია მიკროსიმძლავრის ელექრტოსადგურის შესახებ', size: 12
  pdf.move_down 10
  pdf.text '1. მიკროსიმძლავრის ელექტროსადგურის პირველადი ენერგიის წყარო:', indent_paragraphs: 4
  pdf.table [[" ", '□ მზის     □ ქარის     □ ჰიდრო     □ სხვა ____________________']] do |t|
    t.column(0..1).style borders: []
  end
  pdf.text '(გთხოვთ, დააკონკრეტოთ)', size: 6, height: 7, indent_paragraphs: 210
  pdf.move_down 20
  pdf.text '2. მიკროსიმძლავრის ელექტროსადგურის დადგმული სიმძლავრე (კვტ): _________', indent_paragraphs: 4
  pdf.move_down 20
  pdf.text '3. მიკროსიმძლავრის ელექტროსადგურის მწარმოებელი და მოდელი (თუ ვნობილია)', indent_paragraphs: 4
  pdf.table [[' ', ' ']], column_widths: [20,500] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 20
  pdf.text '4. მიკროსიმძლავრის ელექტროსადგურის ქსელში ჩართვის სქემა', indent_paragraphs: 4
  pdf.table [[" ", '□ სინქრონული      ან     □ ინცვეტრორით']] do |t|
    t.column(0..1).style borders: []
  end
  pdf.move_down 20
  pdf.text 'III. თანდართული დოკუმენტაცია:', size: 12
  pdf.move_down 10
  pdf.text 'ა) მიკროსიმძლავრის ელექტროსადგურის მიერთების საფასურის გადახდის დამადასტურებელი', indent_paragraphs: 4
  pdf.move_down 5
  pdf.text 'სატუთი □ და გადახდილი თანხა სიტყვიერად: ___________________________________________', indent_paragraphs: 4
  pdf.move_down 20
  pdf.text 'ბ) სხვა თანდართული დოკუმენტაცია (სურვილის შემთვევაში): ', indent_paragraphs: 4
  pdf.table [[' ', ' ']], column_widths: [20,500] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 20
  pdf.text 'IV. განაცხადის პირობები', size: 12
  pdf.move_down 10
  pdf.text 'ამ განაცხადის ხელმოწერით ვადასტურებ, რომ განაწილების ლიცენზიატის მიერ ამ განაცხადის მიღებისა და მასში ასახული პირობების შესრულების შემთხვევაში, შევასრულებ საქართველოს ენერგეტიკისა და წყალმომარაგების მარეგულირებელი კომისიის მიერ დამტკიცებული „ელექტროენერგიის (სიმძლავრის) მიწოდებისა და მოხმარების წესებით“ განსაზღვრულ ვალდებულებებს, მათ შორის დროულად გადავიხდი ჩემ მიერ მოთხოვნილ მომსახურებაზე დადგენილ საფასურს.', align: :justify

  pdf.move_down 30
  pdf.text 'განმცხადებლის ხელმოწერა ____________________________________________________', indent_paragraphs: 50
end