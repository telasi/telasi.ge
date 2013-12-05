# -*- encoding : utf-8 -*-
module Network::CalculationUtils
  def distribute(items, amount)
    n = items.size
    total_amount = (amount * 100).to_i
    if n > 0 and total_amount > 0
      per_item = total_amount / n
      remainder = total_amount - per_item * items.size
      items.each_with_index do |x, i|
        addition = 0
        addition = 1 and remainder -= 1 if i + remainder  > n - 1
        yield x, (per_item + addition) / 100.0
      end
    else
      items.each do |x|
        yield x, 0
      end
    end
  end
end
