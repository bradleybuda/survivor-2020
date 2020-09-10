#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'

url = 'https://projects.fivethirtyeight.com/2020-nfl-predictions/games/'
doc = Nokogiri::HTML(open(url))

lines = []

doc.css('#games .week').each do |week|
  week_name = week.css('h3').first.text
  week_index = nil

  if week_name =~ /Week (\d+)/
    week_number = $1.to_i
    week_index = week_number - 1
  else
    raise "could not get week number"
  end

  week.css('.game').each do |game|
    teams = game.css('.game-body tr').map do |team_in_game|
      team_name = team_in_game.css('.team').text.strip
      win_probability_s = team_in_game.css('.chance').text.strip
      win_probability = win_probability_s.gsub('%','').to_f / 100.0
      [team_name, win_probability]
    end

    lines << [week_index] + teams.flatten
  end
end

File.open('win_probabilities.csv', 'w') do |output|
  lines.sort.each { |line| output.puts(line.join(',')) }
end
