# Provides #Time.wnum

class Time
  def wnum
    strftime('%W').to_i
  end

  def week_key
    strftime('%Y.%W')
  end
end