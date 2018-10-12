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

def page1(pdf)
  default_font(pdf, 8)
  pdf.text %Q{ დანართი 1
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
  pdf.text 'გამანაწილებელ ქსელზე ახალი მომხარებლის მიერთების მოთხოვნის შესახებ', align: :center, size: 10
  pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
    pdf.move_down 3
    pdf.text 'განმცხადებლის საყურადღებოდ!', align: :center, size: 10
    pdf.indent 5,5 do
      pdf.text %Q{ განაწილების ლიცენზიატი ვალდებულია, დაუყოვნებლივ დაარეგისტრიროს განმცხადებლის მიერ წარდგენილი ნებისმიერი სახის წერილობითი განცხადება (განაცხადი) და დაუყოვნებლივ გასცეს განაცხადის რეგისტრაციის ნომერი, რეგისტრაციის თარიღის მითითებით.
    „გამანაწილებელ ქსელზე ახალი მომხმარებლის მიერთების მოთხოვნის შესახებ“ განაცხადი დამტკიცებულია კომისიის 2011 წლის 22 ნოემბრის #30/1 გადაწყვეტილებით, განმცხადებელი არ არის ვალდებული, მიაწოდოს განაწილების ლიცენზიატს რაიმე დამატებითი ინფორმაცია ან დოკუმენტი გარდა იმისა, რაც გათვალისწინებულია კომისიის მიერ დამტკიცებული განაცხადის ფორმით.
    განაწილების ლიცენზიატის ვალდებულებას არ წარმოადგენს ელექტრომომარაგებისათვის მომხმარებლის შიდა ქსელის მზადყოფნის დადგენა. ახალი მომხმარებელი პასუხისმგებელია-უფლებამოსილია მის მფლობელობაში არსებული შიდა ქსელის, მათ შორის, აღრიცხვის კვანძის შემდეგ მოწყობილი გამთიშველისა და სხვა მოწყობილობის/დანადგარის პირველად ჩართვასა და მათ უსაფრთხოებაზე.
    დაუშვებელია მიერთების მსურველის (განმცხადებლის) მიერ მიერთების უზრუნველყოფისათვის საჭირო საშუალებების შეძენა ან/და გამანაწილებელ ქსელზე მოთხოვნილი მიერთებისათვის საჭირო სამუშაოების წარმოება, მასთან დაკავშირებული საპროექტო-სამშენებლო სამუშაოების დაგეგმვაში ან შესრულებაში ან რაიმე სახის თანხმობის, ან/და ნებართვის მიღებაში მონაწილეობა.
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
  pdf.move_down 15
  pdf.text 'I. ზოგადი ინფორმაცია ', size: 12
  pdf.table [[{ content: '1. ელექტროენერგიის განაწილების ლიცენზიანტი:', height: @table_height }, { content: 'სს თელასი', height: @table_height }], [{ content: '2. მიერთების მსურველი (განმცხადებლი):', height: @table_height }, { content: @application.rs_name, height: @table_height }]],
    column_widths: [250, 250] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.move_down 3
  pdf.text '(სახელი, გვარი ან იურიდიული პირის შემთხვევაში მისი სახელი (სახელწოდება)', size: 6, align: :center, height: 7
  pdf.table [[{content: '3. პირადი ნომერი/საიდენტიფიკაციო კოდი:', height: @table_height }, { content: (@application.show_tin_on_print ? @application.rs_tin : ''), height: @table_height }]],
    column_widths: [200, 300] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  #pdf.move_down 5
  #pdf.text '(იურიდიული პირის ან ინდმეწარმის ან სხვა მეწარმე სუბიექტის შემთხვევაში)', size: 6, align: :center, height: 9
  pdf.table [[{content: '4. მიერთების მსურველის (განმცხადებლის) საკონტაქტო ინფორმაცია:', height: @table_height}]] do |t|
    t.column(0).style borders: []
  end
  pdf.table [[{content: '4.1. მისამართი:', height: @table_height }, {content: @application.address, height: @table_height }]],
    column_widths: [100, 400] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.table [[{content: '4.2. მობილური:', height: @table_height }, {content: @application.mobile, height: @table_height }, {content:  'ელ.ფოსტა:', height: @table_height }, {content: @application.email, height: @table_height }]],
    column_widths: [100,100,70,230] do |t|
    t.column(0..3).style borders: []
    t.column(1).style borders: [:bottom]
    t.column(3).style borders: [:bottom]
  end
  pdf.table [[{content: '5. მიერთების მსურველის (განმცხადებლის) საბანკო რეკვიზიტები:', height: @table_height}, {content: "#{@application.bank_code}, #{@application.bank_name}, #{@application.bank_account}", height: @table_height }]], column_widths: [nil, 205] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
  pdf.table [[{content: '6. ადგილი (მისამართი) სადაც უნდა მოხდეს ელექტრომომარაგება:', height: @table_height}, {content: '', height: @table_height}], [{content: "#{@application.address_code}, #{@application.work_address || @application.address}", colspan: 2, height: @table_height}]], column_widths: [nil,200] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
    t.row(1).style borders: [:bottom]
  end
  pdf.table [['7. განაწილების ლიცენზიატის მიერ შეტყობინების გაგზავნის ფორმა:']] do |t|
    t.column(0).style borders: []
  end
  pdf.text "☐ წერილობითი ☒ ელექტრონული", size: 9, indent_paragraphs: 20
  pdf.table [['8. გესაჭიროებათ თუ არა საგადასახადო ანგარიშ-ფაქტურის გამოწერა?']] do |t|
    t.column(0).style borders: []
  end
  pdf.text @application.need_factura ? "☒ დიახ ☐ არა" : "☐ დიან ☒ არა", size: 9, indent_paragraphs: 20
  pdf.table [['9. მიკროსიმძლავრის ელექტროსადგურის გამანაწილებელ ქსელზე მიერთების მოთხოვნა:']] do |t|
    t.column(0).style borders: []
  end
  pdf.table [[{content: '', height: @table_height }, {content: '☐ არა ☐ დიახ ☐ დადებითი პასუხის შემთხვევაში:', height: @table_height }, {content: '', height: @table_height }]], column_widths: [nil, nil, 250] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: []
    t.column(2).style borders: [:bottom]
  end
  pdf.move_down 2
  pdf.text '(მიუთითეთ განაცხადით მოთხოვნილი გამანაწილებელ ქსელზე მისაერთებელი მიკრო სიმძლავრის ელექტროსადგურების რაოდენობა)', align: :center, size: 6, indent_paragraphs: 30
end

def page2(pdf)
  pdf.text 'ერთი ან ორი აბონენტის მიერთების მოთხოვნის შემთხვევაში ☒', size: 15, align: :center
  pdf.text '(ივსება მხოლოდ მიერთების შედეგად  ერთი ან ერთდროულად ორი აბონენტის რეგისტრაციის მოთხოვნის შემთხვევაში)', size: 8, align: :center
  pdf.move_down 5
  pdf.text 'განაცხადით მოთხოვნილი აბონენტთა რაოდენობა: ☒ ერთი; □ ორი.'
  #pdf.move_down 20
  width = pdf.bounds.width / 2
  pdf.table [['-1-', '-2-'],
    ['1. დაზუსტებული მისამართი, სადაც უნდა მოხდეს ელექტრომომარაგება:'] * 2,
    [(@application.work_address || @application.address), ''],
    ['2.აბონენტის (მოხმარებული ელ. ენერგიის საფასურის გადახდაზე პასუხისმგებელი პირის) სახელი, გვარი ან იურიდიული პირის სახელი:'] * 2,
    [@application.rs_name, ''],
    ['2.1. პირადი ნომერი ან საიდენტიფიკაციო კოდი:'] * 2,
    [@application.rs_tin, ''],
    ['3. ელექტროენერგიის მოხმარების მიზანი:'] * 2,
    [@application.personal_use ? '☒ საყოფაცხოვრებო, □ არასაყოფაცხოვრებო.' : '□ საყოფაცხოვრებო, ☒ არასაყოფაცხოვრებო.', '□ საყოფაცხოვრებო, □ არასაყოფაცხოვრებო.'],
    ['4. უძრავი ქონების საკადასტრო კოდი (სადაც უნდა მოხდეს ელექტრომომარაგება):'] * 2,
    [@application.address_code, ''],
    ['5. მოთხოვნილი ძაბვის საფეხური:'] * 2,
    ["#{(@application.voltage == '220' ? '☒' : '□')} 220ვ;  #{(@application.voltage == '380' ? '☒' : '□')} 380ვ;  #{(@application.voltage == '6/10' ? '☒' : '□')} 6/10კვ", '□ 220ვ;  □ 380ვ;  □ 6/10კვ'],
    ['6. მოთხოვნილი სიმძლავრე:'] * 2,
    ["#{@application.power} კვტ", ''],
    ['7. გამანაწილებელ ქსელზე მიერთების საფასური (შეთავაზებული პაკეტის მიხედვით):'] * 2,
    ["#{@application.amount} GEL", ''],
    ['8. ივსება, მიკროსიმძლავრის ელექტროსადგურის მიერთების მოთხოვნის შემთხვევაში: □'] * 2,
    ['8.1. მიკროსიმძლავრის ელექტროსადგურის დადგმული სიმძლავრე (კვტ): ___________'] * 2,
    ['8.2. მიკროსიმძლავრის ელექტროსადგურის მიერთების საფასური: _________________.'] * 2,
  ], column_widths: [ width, width ] do |t|
    t.column(0).style borders: [:left, :right]
    t.column(1).style borders: [:right]
    t.row(0).style borders: [:left, :right, :top]
    t.row(2).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(4).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(6).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(8).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(10).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(12).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(14).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(16).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(19).style borders: [:left, :right, :bottom], align: :justify, size: 10
  end
  pdf.move_down 3
  pdf.text 'შენიშვნა: საყოფაცხოვრებო მომხმარებლის შემთხვევაში – უძრავი ქონების საკადასტრო კოდის ნაცვლად, შესაძლებელია, განაცხადზე თანდართულ იქნეს ნებისმიერი დოკუმენტი, რომელიც წარმოადგენს საკუთრების უფლების რეგისტრაციის საფუძველს.'
  pdf.move_down 15
  pdf.text 'II. ერთდროულად სამი ან სამზე მეტი აბონენტის მიერთების მოთხოვნის შემთხვევაში □', size: 15, align: :center
  pdf.text '(ივსება მხოლოდ მიერთების შედეგად ერთდროულად სამი ან სამზე მეტი აბონენტთა რეგისტრაციის მოთხოვნის შემთხვევაში)', align: :center, size: 6
  pdf.move_down 7
  pdf.text '1. განაცხადით მოთხოვნილი აბონენტთა (ინდ.აღრიცხვა) საერთო რაოდენობა: ___'
  pdf.move_down 7
  pdf.text '2. საყოფაცხოვრებო და არასაყოფაცხოვრებო აბონენტთა რაოდენობა: საყოფაცხოვრებო ____ არა საყოფაცხოვრებო ___ განცალკევებული აღრიცხვა ___ (განათება, ლიფტი და სხვა მიზნებისთვის)'
  pdf.move_down 7
  pdf.text '3. უძრავი ქონების საკადასტრო კოდი (სადაც უნდა მოხდეს ელექტრომომარაგება): __________________'
  pdf.move_down 7
  pdf.text '4. საცხოვრებელი ბინის, საწარმოს ან სხვა სახის ობიექტის (ან ობიექტების) სამშენებლო-საპროექტო დოკუმენტაციით განსაზღვრული (დადგენილი) მისაერთებელი სიმძლავრე: ____'
  pdf.move_down 7
  pdf.text '5. გამანაწილებელ ქსელზე მიერთების საფასური (შეთავაზებული პაკეტის მიხედვით): ______'
end

def page2_multi(pdf)
  pdf.text 'ერთი ან ორი აბონენტის მიერთების მოთხოვნის შემთხვევაში □', size: 15, align: :center
  pdf.text '(ივსება მხოლოდ მიერთების შედეგად  ერთი ან ერთდროულად ორი აბონენტის რეგისტრაციის მოთხოვნის შემთხვევაში)', size: 8, align: :center
  pdf.move_down 5
  pdf.text 'განაცხადით მოთხოვნილი აბონენტთა რაოდენობა: ☒ ერთი; □ ორი.'
  #pdf.move_down 20
  width = pdf.bounds.width / 2
  pdf.table [['-1-', '-2-'],
    ['1. დაზუსტებული მისამართი, სადაც უნდა მოხდეს ელექტრომომარაგება:'] * 2,
    ['', ''],
    ['2.აბონენტის (მოხმარებული ელ. ენერგიის საფასურის გადახდაზე პასუხისმგებელი პირის) სახელი, გვარი ან იურიდიული პირის სახელი:'] * 2,
    ['', ''],
    ['2.1. პირადი ნომერი ან საიდენტიფიკაციო კოდი:'] * 2,
    ['', ''],
    ['3. ელექტროენერგიის მოხმარების მიზანი:'] * 2,
    ['□ საყოფაცხოვრებო, □ არასაყოფაცხოვრებო.', '□ საყოფაცხოვრებო, □ არასაყოფაცხოვრებო.'],
    ['4. უძრავი ქონების საკადასტრო კოდი (სადაც უნდა მოხდეს ელექტრომომარაგება):'] * 2,
    ['', ''],
    ['5. მოთხოვნილი ძაბვის საფეხური:'] * 2,
    ['□ 220ვ;  □ 380ვ;  □ 6/10კვ', '□ 220ვ;  □ 380ვ;  □ 6/10კვ'],
    ['6. მოთხოვნილი სიმძლავრე:'] * 2,
    ['', ''],
    ['7. გამანაწილებელ ქსელზე მიერთების საფასური (შეთავაზებული პაკეტის მიხედვით):'] * 2,
    ['', ''],
    ['8. ივსება, მიკროსიმძლავრის ელექტროსადგურის მიერთების მოთხოვნის შემთხვევაში: □'] * 2,
    ['8.1. მიკროსიმძლავრის ელექტროსადგურის დადგმული სიმძლავრე (კვტ): ___________'] * 2,
    ['8.2. მიკროსიმძლავრის ელექტროსადგურის მიერთების საფასური: _________________.'] * 2,
  ], column_widths: [ width, width ] do |t|
    t.column(0).style borders: [:left, :right]
    t.column(1).style borders: [:right]
    t.row(0).style borders: [:left, :right, :top]
    t.row(2).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(4).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(6).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(8).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(10).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(12).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(14).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(16).style borders: [:left, :right, :bottom], align: :center, size: 10
    t.row(19).style borders: [:left, :right, :bottom], align: :justify, size: 10
  end
  pdf.move_down 3
  pdf.text 'შენიშვნა: საყოფაცხოვრებო მომხმარებლის შემთხვევაში – უძრავი ქონების საკადასტრო კოდის ნაცვლად, შესაძლებელია, განაცხადზე თანდართულ იქნეს ნებისმიერი დოკუმენტი, რომელიც წარმოადგენს საკუთრების უფლების რეგისტრაციის საფუძველს.'
  pdf.move_down 15
  pdf.text 'II. ერთდროულად სამი ან სამზე მეტი აბონენტის მიერთების მოთხოვნის შემთხვევაში ☒', size: 15, align: :center
  pdf.text '(ივსება მხოლოდ მიერთების შედეგად ერთდროულად სამი ან სამზე მეტი აბონენტთა რეგისტრაციის მოთხოვნის შემთხვევაში)', align: :center, size: 6
  pdf.move_down 7
  pdf.table [[{ content: '1. განაცხადით მოთხოვნილი აბონენტთა (ინდ.აღრიცხვა) საერთო რაოდენობა: ', height: @table_height }, { content: @application.abonent_amount.to_s, height: @table_height }]],
    column_widths: [360, 140] do |t|
    t.column(0).style borders: [], padding: 0
    t.column(1).style borders: [], padding: 0
  end
  pdf.move_down 7
  pdf.text '2. საყოფაცხოვრებო და არასაყოფაცხოვრებო აბონენტთა რაოდენობა: საყოფაცხოვრებო ____ არა საყოფაცხოვრებო ___ განცალკევებული აღრიცხვა ___ (განათება, ლიფტი და სხვა მიზნებისთვის)'
  pdf.move_down 7
  pdf.table [[{ content: '3. უძრავი ქონების საკადასტრო კოდი (სადაც უნდა მოხდეს ელექტრომომარაგება): ', height: @table_height }, { content: @application.address_code, height: @table_height }]],
    column_widths: [380, 120] do |t|
    t.column(0).style borders: [], padding: 0
    t.column(1).style borders: [], padding: 0
  end
  pdf.move_down 7
  pdf.text '4. საცხოვრებელი ბინის, საწარმოს ან სხვა სახის ობიექტის (ან ობიექტების) სამშენებლო-საპროექტო დოკუმენტაციით'
  pdf.table [[{ content: 'განსაზღვრული (დადგენილი) მისაერთებელი სიმძლავრე: ', height: @table_height }, { content: @application.power.to_s, height: @table_height }]],
    column_widths: [260, 240] do |t|
    t.column(0).style borders: [], padding: 0
    t.column(1).style borders: [], padding: 0
  end
  pdf.move_down 7
  pdf.table [[{ content: '5. გამანაწილებელ ქსელზე მიერთების საფასური (შეთავაზებული პაკეტის მიხედვით): ', height: @table_height }, { content: "#{@application.amount} GEL", height: @table_height }]],
    column_widths: [380, 120] do |t|
    t.column(0).style borders: [], padding: 0
    t.column(1).style borders: [], padding: 0
  end
end

def page3(pdf)
  pdf.text 'III. თანდართული დოკუმენტაცია:', size: 15, align: :center
  pdf.move_down 20
  pdf.text 'ა) საფასურის გადახდის დამადასტურებელი საბუთი: ☒ და გადახდილი თანხა სიტყვიერად: __________________________ ;'
  pdf.move_down 10
  pdf.text 'ბ) ერთდროულად სამი ან სამზე მეტი აბონენტის რეგისტრაციის მოთხოვნის შემთხვევაში: □'
  pdf.move_down 10
  pdf.text 'ბ.ა) საპროექტო ორგანიზაციის მიერ დამოწმებული, მისაერთებელი ობიექტის "პროექტის ელექტრულ ნაწილზე ახსნა–განმარტებითი ბარათი" (რომელიც დამუშავებულია, დამტკიცებული პროექტის არქიტექტურულ–სამშენებლო ნაწილის მონაცემების საფუძველზე) □'
  pdf.move_down 10
  pdf.text 'ბ.ბ) აბონენტების მიხედვით დაზუსტებული მისამართები მოთხოვნილი ძაბვის საფეხური და მოთხოვნილი სიმძლავრეები -- შევსებული დანართი 1.1 მიხედვით; □'
  pdf.move_down 10
  pdf.text 'გ) მიკროსიმძლავრის ელექტროსადგურის გამანაწილებელ ქსელზე მიერთების პირობები (მოთხოვნის შემთხვევაში) – შევსებული დანართი 1.2 მიხედვით. □'
  pdf.move_down 10
  pdf.text 'დ) სხვა თანდართული დოკუმენტაცია (სურვილის შემთხვევაში): __________________________________________________'

  pdf.move_down 40
  pdf.text 'IV. განაცხადის პირობები', size: 15, align: :center
  pdf.move_down 20
  pdf.text 'ამ განაცხადის ხელმოწერით ვადასტურებ განაწილების ლიცენზიატის მიერ ამ განაცხადის მიღებას და მასში ასახული პირობების შესრულების შემთხვევაში, შევასრულებ საქართველოს ენერგეტიკისა და წყალმომარაგების მარეგულირებელი ეროვნული კომისიის მიერ დამტკიცებული „ელექტროენერგიის (სიმძლავრის) მიწოდებისა და მოხმარების წესებით“ განსაზღვრულ ვალდებულებებს, მათ შორის დროულად გადავიხდი ჩემ მიერ მოთხოვნილ მომსახურებაზე დადგენილ საფასურს.'

  pdf.move_down 40
  pdf.table [['განმცხადებლის ხელმოწერა:', '']], column_widths: [150, 270] do |t|
    t.column(0).style borders: []
    t.column(1).style borders: [:bottom]
  end
end

def page4(pdf)
  pdf.text 'დანართი 1.1', align: :right, size: 10
  pdf.move_down 10
  pdf.text 'აბონენტების მიხედვით დაზუსტებული მისამართები, მოთხოვნილი ძაბვის საფეხური და მოთხოვნილი სიმძლავრეები', align: :center, size: 12
  pdf.move_down 10
  @empty_cell_height = 30
  @empty_cell_content = { content: '', height: @empty_cell_height}
  pdf.table [['№', 'აბონენტის დაზუსტებული მისამართი', 'აბონენტის (მოხმარებული ელ. ენერგიის საფასურის გადახდაზე პასუხისმგებელი პირის) სახელი, გვარი ან იურიდიული პირის სახელი', 'პირადი ნომერი ან იურიდიული პირის საიდენტიფიკაციო კოდი', {content: 'საკადასტრო კოდი <sup>1</sup>', inline_format: :true }, 'მოთხოვნილი ძაბვის საფეხური (0,220, 0,380 ან 6/10 კვ.)', {content: 'მოთხოვნილი სიმძლავრე კვტ. <sup>2</sup>', inline_format: :true}],
  ['1', (@application.work_address || @application.address), @application.rs_name, (@application.show_tin_on_print ? @application.rs_tin : ''), @application.address_code, @application.voltage, @application.power],
  [@empty_cell_content] * 7,
  [@empty_cell_content] * 7,
  [@empty_cell_content] * 7,
  [@empty_cell_content] * 7,
  [@empty_cell_content] * 7,
  [@empty_cell_content] * 7], column_widths: [30, 120, 170, 120, 120, 120, 100] do |t|
    t.column(0).style borders: [:left, :right, :bottom, :top], size: 10
    t.column(1).style borders: [:left, :right, :bottom, :top], size: 10
    t.column(2).style borders: [:left, :right, :bottom, :top], size: 10
    t.column(3).style borders: [:left, :right, :bottom, :top], size: 10
    t.column(4).style borders: [:left, :right, :bottom, :top], size: 10
    t.column(5).style borders: [:left, :right, :bottom, :top], size: 10
    t.column(6).style borders: [:left, :right, :bottom, :top], size: 10
  end
  pdf.move_down 20
  pdf.text '______________________________'
  pdf.move_down 5
  pdf.text '<sup>1</sup> შენიშვნა: საყოფაცხოვრებო მომხმარებლის შემთხვევაში, უძრავი ქონების საკადასტრო კოდის ნაცვლად, განაცხადზე შესაძლებელია, თანდართული იქნეს ნებისმიერი დოკუმენტი, რომელიც წარმოადგენს საკუთრების უფლების რეგისტრაციის საფუძველს;', size: 9, inline_format: :true
  pdf.move_down 5
  pdf.text '<sup>2</sup> შენიშვნა: მოცემულ შემთხვევაში მისაერთებელი სიმძლავრის განსაზღვრა არ ხდება „მოთხოვნილი სიმძლავრის“ სვეტში არსებული მონაცემების დაჯამებით, არამედ – სამშენებლო-საპროექტო დოკუმენტაციით განსაზღვრული (დადგენილი) მისაერთებელი სიმძლავრის მიხედვით.', size: 9, inline_format: :true
end

def page5(pdf)
  pdf.text 'დანართი 1.2', align: :right, size: 10
  pdf.move_down 10
  pdf.text 'გამანაწილებელ ქსელზე მიკროსიმძლავრის ელექტროსადგურის მიერთების მოთხოვნა', align: :center, size: 12
  pdf.move_down 10
  pdf.table [['1.', 'აბონენტის (მოხმარებული ელ. ენერგიის საფასურის გადახდაზე პასუხისმგებელი პირის) სახელი, გვარი ან იურიდიული პირის სახელი', ''],
             ['2.', 'პირადი ნომერი ან იურიდიული პირის საიდენტიფიკაციო კოდი', ''],
             ['3.', 'აბონენტის დაზუსტებული მისამართი', ''],
             ['4.', 'მოთხოვნილი ძაბვის საფეხური (გამანაწილებელ ქსელზე მიერთების საფეხური - 0,220, 0,380 ან 6/10 კვ.)', ''],
             ['5.', 'მოთხოვნილი სიმძლავრე, კვტ (გამანაწილებელ ქსელზე მიერთების სიმძლავრე)', ''],
             ['6.', 'მიკროსიმძლავრის ელექტროსადგურის პირველადი ენერგიის წყარო:', { content: '□ მზის, □ ქარის □, ჰიდრო □, ან სხვა:
___________________________
(გთხოვთ, დააზუსტოთ)', align: :center}],
             ['7.', 'მიკროსიმძლავრის ელექტროსადგურის დადგმული სიმძლავრე (კვტ)', ''],
             ['8.', 'მიკროსიმძლავრის ელექტროსადგურის მწარმოებელი და მოდელი (თუ ცნობილია)', ''],
             ['9.', 'მიკროსიმძლავრის ელექტროსადგურის ქსელში ჩართვის სქემა:', 'სინქრონული □, ან ინვერტორით □']], column_widths: [30, 300, 200] do |t|
    t.column(0).style borders: [:left, :right, :bottom, :top], size: 10
    t.column(1).style borders: [:left, :right, :bottom, :top], size: 10
    t.column(2).style borders: [:left, :right, :bottom, :top], size: 10
  end
end

prawn_document(page_size: 'A4', margin: [30, 30]) do |pdf|
  page1(pdf)
  pdf.start_new_page
  if @application.abonent_amount > 2
    page2_multi(pdf)
  else 
    page2(pdf)
  end
  pdf.start_new_page
  page3(pdf)
  pdf.start_new_page(layout: :landscape)
  page4(pdf)
  pdf.start_new_page(layout: :portrait)
  page5(pdf)
end
