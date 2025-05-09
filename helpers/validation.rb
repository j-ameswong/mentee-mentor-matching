# Provide various functions for validating data
module Validation
  def match(str1, str2)
    return false unless str1 && str2
    str1 == str2
  end

  def valid_email?(str)
    return false if str.nil?

    str.match?(/\A\S+@\S+\Z/) && str.include?(".ac.uk")
  end

  def valid_input?(str)
    return false if str.nil?

    str.match?(/\A[A-Za-z0-9]+\z/)
  end

  def str_digits?(str)
    return false if str.nil?

    str.match?(/^(\d)+$/)
  end

  def str_length?(str, len)
    return false if str.nil?

    str.length == len
  end

  def str_min_length?(str, min_len)
    return false if str.nil?

    str.length >= min_len
  end

  def str_max_length?(str, max_len)
    return false if str.nil?

    str.length <= max_len
  end

  def str_uk_telephone?(str)
    return false if str.nil?

    str = str.delete(" ").delete("-")
    str.start_with?(str, "0") && str_min_length?(str, 10) && str_max_length?(str, 11)
  end

  def str_yyyy_mm_dd_date?(str)
    return false if str.nil?

    str = str.to_s
    y, m, d = str.split("-")

    return Date.valid_date?(y.to_i, m.to_i, d.to_i) if str_length?(y, 4)

    false
  end

  def html_unsafe?(str)
    return false if str.nil?

    !!(str =~ /[<>&"'\/]/)
  end

  def valid_pic?(pic_data)
    return false if pic_data.nil?

    file_ext = pic_data[:filename].split(".").last if pic_data && pic_data[:filename]
    return false unless file_ext

    valid_extensions = %w[jpg jpeg png]
    valid_extensions.include?(file_ext.downcase)
  end
end