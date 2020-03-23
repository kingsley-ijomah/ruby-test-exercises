# frozen_string_literal: true
require 'uri'
require 'net/http'

module YourRuby
  module_function

  SECONDS_IN_HOUR = 60 * 60
  SECONDS_IN_DAY = 24 * SECONDS_IN_HOUR

  def fizzbuzz(max)
    result = []
    1.upto(max) do |i|
      if i % 5 == 0 and i % 3 == 0
        result << 'fizzbuzz'
      elsif i % 3 == 0
        result << 'fizz'
      elsif i % 5 == 0
        result << 'buzz'
      else
        result << i
      end
    end
    result
  end

  def smallest_rectangle_of_aspect(ratio, rectangle)
    height, width = rectangle
    if (height * ratio) >= width
      [height, height * ratio]
    else
      [width / ratio, width]
    end
  end

  def parse_time(str)
    str.split(':').map(&:to_i).inject(0) do |sum, i| 
      (sum + i) * 60
    end
  end

  def finish_time_for_day(date, opening_hours)
    opening_hours = opening_hours[date.strftime("%a")]&.[](1)
    return false unless opening_hours

    Time.at(
      midnight(date).to_i + parse_time(opening_hours)
    )
  end

  def start_time_for_day(date, opening_hours)
    closing_hours = opening_hours[date.strftime("%a")]&.[](0)
    return false unless closing_hours

    Time.at(
      midnight(date).to_i + parse_time(closing_hours)
    )
  end

  def calculate_completion_time(placed_at, num_hours, opening_hours)
    hours = opening_hours[placed_at.strftime("%a")]
    work_hours = (parse_time(hours[1]) - parse_time(hours[0]))/3600.0 rescue 0

    if num_hours > work_hours
      num_hours = num_hours - work_hours
      placed_at = placed_at + SECONDS_IN_DAY
      return calculate_completion_time(placed_at, num_hours, opening_hours)
    end

    start_time = start_time_for_day(placed_at, opening_hours)
    finish_time = finish_time_for_day(placed_at, opening_hours)

    ready_at = placed_at + seconds_in_hours(num_hours)

    if placed_at < start_time
      ready_at = midnight(placed_at) +
                  parse_time(start_time.strftime("%H:%M")) +
                  seconds_in_hours(num_hours)
    end

    if placed_at > finish_time
      ready_at = midnight(placed_at) +
                 parse_time(finish_time.strftime("%H:%M")) +
                 seconds_in_hours(num_hours)
    end

    overdue_in_seconds =
      parse_time(ready_at.strftime("%H:%M")) - parse_time("#{finish_time.hour}:#{finish_time.min}")

    if overdue_in_seconds > 0
      ready_at = ready_at + SECONDS_IN_DAY * next_business_day_offset(placed_at.wday)
      new_opening_hours = opening_hours[placed_at.strftime("%a")]

      ready_at = midnight(ready_at) + parse_time(new_opening_hours[0]) + overdue_in_seconds
    end
    ready_at
  end

  def duckduckwhy(str, num_results)
    url = URI.parse("https://duckduckgo.com/html/?q=#{str}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(url.request_uri)
    req['User-agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36'
    response = http.request(req)

    href_regex = /<a class=['|"]result__url['|"]\s+href=?['|"]([^'"]+)['|"]>\s+.*\s+<\/a>/
    response.body.scan(href_regex).first(num_results).flatten
  end

  class << self
    def seconds_in_hours(num_hours)
      num_hours * SECONDS_IN_HOUR
    end

    def midnight(date)
      Time.mktime(
        date.year, date.month, date.day
      )
    end

    def next_business_day_offset(wday)
      case
      when wday < 5 && wday > 0 then 1
      when wday == 5 then 3
      end
    end
  end
end
