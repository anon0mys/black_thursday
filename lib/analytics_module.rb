# Module for analytics calculations
module Analytics
  def standard_deviation(elements, average)
    numerator = sum_square_differences(elements, average)
    denominator = (elements.length - 1)
    Math.sqrt(numerator.to_f / denominator).round(2)
  end

  def sum_square_differences(elements, average)
    elements.map do |element|
      (element - average)**2
    end.reduce(:+)
  end

  def average(elements)
    return 0 if elements == []
    (elements.reduce(:+) / elements.length).round(2)
  end

  def sigma(elements, number_of_sigmas)
    average = average(elements)
    st_dev = standard_deviation(elements, average)
    average + (number_of_sigmas * st_dev)
  end
end
