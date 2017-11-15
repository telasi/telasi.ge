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
  pdf.text %Q{ დანართი 4
    "დამტკიცებულია" }, align: :right, size: 10
  pdf.text %Q{ საქართველოს ენერგეტიკისა და წყალმომარაგების
    მარეგულირებელი ეროვნული კომისიის 
    2011 წლის 22 ნოემბრის №30/1 გადაწყვეტილებით.
    2017 წლის 9 ივნისის #43/35 გადაწყვეტილების მდგომარეობით }, align: :right
  date = @application.created_at
  pdf.table [[{content: 'რეგ. №', height: 20 }, {content: @application.number, height: 20 }, {content: 'თარიღი:', height: @table_height }, {content: "#{date.day} #{month_name(date.month)} #{date.year}", height: 20 }],[{content: '(ივსება განაწილების ლიცენზიატის მიერ)', colspan: 4, height: 20 }]], column_widths: [50, 150, 60, 150] do |t|
    t.column(0).style borders: [], size: 10
    t.column(1).style borders: [:bottom], align: :center, size: 10
    t.column(2).style borders: [], size: 10
    t.column(3).style borders: [:bottom], align: :center, size: 10
    t.row(1).style borders: [], align: :center, size: 6
  end
  pdf.move_down 7
  pdf.text 'განაცხადი', size: 20, align: :center
  pdf.text 'საცალო მომხმარებლის მიერ ელექტროენერგიის მოხმარების სიმძლავრის გაზრდის შესახებ', align: :center, size: 10
  pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
    pdf.move_down 3
    pdf.text 'განმცხადებლის საყურადღებოდ!', align: :center, size: 10
    pdf.move_down 5
    pdf.indent 5,5 do
      pdf.text %Q{ განაწილების ლიცენზიატი ვალდებულია, დაუყოვნებლივ დაარეგისტრიროს განმცხადებლის მიერ წარდგენილი ნებისმიერი სახის წერილობითი განცხადება (განაცხადი) და დაუყოვნებლივ გასცეს განაცხადის რეგისტრაციის ნომერი, რეგისტრაციის თარიღის მითითებით.
      „საცალო მომხმარებლის მიერ ელექტროენერგიის მოხმარების სიმძლავრის გაზრდის შესახებ“ განაცხადი დამტკიცებულია კომისიის 2011 წლის 22 ნოემბრის #30/1 გადაწყვეტილებით, განმცხადებელი არ არის ვალდებული, მიაწოდოს განაწილების ლიცენზიატს რაიმე დამატებითი ინფორმაცია ან დოკუმენტი გარდა იმისა, რაც გათვალისწინებულია კომისიის მიერ დამტკიცებული განაცხადის ფორმით.
      განაწილების ლიცენზიატის ვალდებულებას არ წარმოადგენს ელექტრომომარაგებისათვის მომხმარებლის შიდა ქსელის მზადყოფნის დადგენა. მომხმარებელი პასუხისმგებელია-უფლებამოსილია მის მფლობელობაში არსებული შიდა ქსელის, მათ შორის, აღრიცხვის კვანძის შემდეგ მოწყობილი გამთიშველისა და სხვა მოწყობილობის/დანადგარის პირველად ჩართვასა და მათ უსაფრთხოებაზე.
      დაუშვებელია სიმძლავრის გაზრდის მსურველის (განმცხადებლის) მიერ სიმძლავრის გაზრდის უზრუნველყოფისათვის საჭირო საშუალებების შეძენა ან/და მოთხოვნილი სიმძლავრის გაზრდისათვის საჭირო სამუშაოების წარმოება, მასთან დაკავშირებული საპროექტო-სამშენებლო სამუშაოების დაგეგმვაში ან შესრულებაში ან რაიმე სახის თანხმობის, ან/და ნებართვის მიღებაში მონაწილეობა.
      განმცხადებელი უფლებამოსილია, მისი უფლებების დარღვევის შემთხვევაში, მიმართოს მომსახურე საწარმოს საჩივრებზე რეაგირების სამსახურს, მარეგულირებელ კომისიას მისამართზე: ქ. თბილისი, ა. მიცკევიჩის ქ. #19 ვებ გვერდი: www.gnerc.org ელ. ფოსტა: mail@gnerc.org ტელ: 16216, ან მარეგულირებელ კომისიასთან არსებულ მომხმარებელთა ინტერესების საზოგადოებრივ დამცველს მისამართზე: ქ. თბილისი, ა. მიცკევიჩის ქუჩა #19 ტელ: (032) 2420190; ვებ გვერდი: http://www.pdci.ge ელ. ფოსტა: mail@pdci.ge.“ }, align: :justify, size: 10, indent_paragraphs: 20, position: :center
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
  pdf.table [[{ content: '1. ელექტროენერგიის განაწილების ლიცენზიანტი:', height: @table_height }, { content: 'სს თელასი', height: @table_height }]], column_widths: [230, 250] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 7
  pdf.table [[{ content: '2. განმცხადებლი:', height: @table_height }, { content: @application.rs_name, height: @table_height }]], column_widths: [100, 250] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 7
  pdf.text '(სახელი, გვარი ან იურიდიული პირის შემთხვევაში მისი სახელი (სახელწოდება), ან სხვა პირის შემთხვევაში მისი სახელწოდება)', size: 6, align: :center, height: 7
  pdf.table [[ {content: '3. საიდენტიფიკაციო კოდი:', height: @table_height }, { content: @application.rs_tin, height: @table_height }]],
    column_widths: [130, 200] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 7
  pdf.text '(იურიდიული პირის ან ინდმეწარმის ან სხვა მეწარმე სუბიექტის შემთხვევაში)', size: 6, align: :center, height: 9
  pdf.table [[{content: '4. განმცხადებლის საკონტაქტო ინფორმაცია:', height: @table_height}]] do |t|
    t.column(0).style borders: []
  end
  pdf.move_down 7
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
  pdf.table [[{content: '5. განმცხადებლის საბანკო რეკვიზიტები:', height: @table_height}, {content: "#{@application.bank_code}, #{@application.bank_name}, #{@application.bank_account}", height: @table_height }]], column_widths: [nil, 205] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.table [[{content: '6. აბონენტის №', height: @table_height}, {content: ("#{@application.customer.accnumb.to_ka} -- #{@application.customer.custname.to_ka}" if @application.customer), height: @table_height }]], column_widths: [nil, 205] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 7
  pdf.text '(იურიდიული პირის ან ინდმეწარმის ან სხვა მეწარმე სუბიექტის შემთხვევაში)', size: 6, height: 9, indent_paragraphs: 70
  pdf.table [[{content: '7. ადგილი (მისამართი) სადაც უნდა მოხდეს მისაერთებელი სიმძლავრის გაზრდა: ', height: @table_height}]], column_widths: [505] do |t|
    t.column(0).style borders: []
  end
  pdf.table [['', {content: "#{@application.work_address}", height: @table_height }]], column_widths: [15, 505] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 7
  pdf.table [[{content: '8. უძრავი ქონების საკადასტრო კოდი (ასეთის არსებობის შემთხვევაში):', height: @table_height}, {content: "#{@application.address_code}", height: @table_height }]], column_widths: [nil, 200] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.table [[{content: '9. აბონენტის ელ. მომარაგების ტექნიკური მახასიათებლები (არსებული ტექ. მახასიათებლები):', height: @table_height}]] do |t|
    t.column(0).style borders: []
  end
  pdf.table [[' ', '9.1. ძაბვის საფეხური:', "#{(@application.old_voltage == '220' ? '☒' : '□')} 220ვ;  #{(@application.old_voltage == '380' ? '☒' : '□')} 380ვ;  #{(@application.old_voltage == '6/10' ? '☒' : '□')} 6/10კვ;","სიმძლავრე #{@application.old_power} კვტ;"]] do |t|
    t.column(0..3).style borders: []
  end
  pdf.table [[' ', '9.2. □ საყოფაცხოვრებო ან □არასაყოფაცხოვრებო']] do |t|
    t.column(0..1).style borders: []
  end
  
  pdf.move_down 20
  pdf.text 'II. მოთხოვნა:', size: 12
  pdf.table [[{content: '10. მოთხოვნილი (გაზრდის შედეგად) ელ. მომარაგების ტექნიკური მახასიათებლები:', height: @table_height}]] do |t|
    t.column(0).style borders: []
  end
  pdf.table [[' ', '10.1. ძაბვის საფეხური:', "#{(@application.voltage == '220' ? '☒' : '□')} 220ვ;  #{(@application.voltage == '380' ? '☒' : '□')} 380ვ;  #{(@application.voltage == '6/10' ? '☒' : '□')} 6/10კვ;","სიმძლავრე #{@application.power} კვტ;"]] do |t|
    t.column(0..3).style borders: []
  end
  pdf.table [[' ', '10.2. ელექტროენერგიის მოხმარების მიზანი: □საყოფაცხოვრებო ან□არასაყოფაცხოვრებო']] do |t|
    t.column(0..1).style borders: []
  end
  pdf.table [[' ', '10.3. არასაყოფაცხოვრებოს შემთხვევაში, საქმიანობა','']], column_widths: [nil, nil, 200] do |t|
    t.column(0..1).style borders: []
    t.column(2).style borders: [:bottom]
  end
  pdf.table [[{content: '11. დამატებითი ინფორმაცია (სურვილის შემთხვევაში):', height: @table_height}]] do |t|
    t.column(0).style borders: []
  end
  pdf.move_down 5
  pdf.text '________________________________________________________________________________________________________________', indent_paragraphs: 20
  pdf.move_down 5
  pdf.text '12. განაწილების ლიცენზიატის მიერ შეტყობინების გაგზავნის ფორმა:□ წერილობითი ან ☒ ელექტრონული.', indent_paragraphs: 5
  pdf.move_down 5
  pdf.text '13. გესაჭიროებათ საგადასახადო ანგარიშ-ფაქტურა:', indent_paragraphs: 5
  pdf.move_down 5
  pdf.text (@application.need_factura ? '☒ დიახ  ☐ არა' : '☐ დიახ  ☒ არა' ), indent_paragraphs: 60

  pdf.move_down 20
  pdf.text 'III. თანდართული დოკუმენტაცია:', size: 12
  pdf.move_down 10
  pdf.text '14. სიმძლავრის გაზრდისთვის დადგენილი საფასურის გადახდის დამადასტურებელი საბუთი □.', indent_paragraphs: 5
  pdf.text 'საფასურის 50% □; ან 100% □', indent_paragraphs: 30
  pdf.text '(მონიშნეთ წინასწარ გადახდილი საფასურის ოდენობა)', size: 6, height: 9, indent_paragraphs: 30
  pdf.text '15. მონიშნეთ, თუ განმცხადებელი და აბონენტი სხვადასხვა პირია, ', indent_paragraphs: 5
  pdf.text 'უძრავი ქონების მესაკუთრის წერილობითი თანხმობა □.', indent_paragraphs: 25
  pdf.text '16. სხვა თანდართული დოკუმენტაცია (განმცხადებლის სურვილის შემთხვევაში): _____________________ .', indent_paragraphs: 5
  pdf.text '17. დანართი ___ გვერდი.', indent_paragraphs: 5

  pdf.move_down 20
  pdf.text 'IV. განაცხადის სხვა პირობები', size: 12
  pdf.move_down 10
  pdf.text '18. ამ განაცხადის ხელმოწერით ვადასტურებ, რომ განაწილების ლიცენზიატის მიერ ამ განაცხადის მიღებისა და მასში ასახული პირობების შესრულების შემთხვევაში, შევასრულებ საქართველოს ენერგეტიკისა და წყალმომარაგების მარეგულირებელი ეროვნული კომისიის მიერ დამტკიცებული „ელექტროენერგიის (სიმძლავრის) მიწოდებისა და მოხმარების წესებით“ განსაზღვრულ ვალდებულებებს, მათ შორის დროულად გადავიხდი სიმძლავრის გაზრდის საფასურს.', align: :justify

  pdf.move_down 30
  pdf.text 'განმცხადებლის ხელმოწერა ____________________________________________________', indent_paragraphs: 50
end