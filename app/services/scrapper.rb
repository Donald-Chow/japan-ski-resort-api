require 'nokogiri'
require 'open-uri'

class Scrapper

  def initialize(url)
    @url = url
  end

  def call
    doc = Nokogiri::HTML(URI.open(@url))
    name = doc.search(".site_title p").children.first.text.strip
    prefecture = doc.search(".site_title p small").text.strip
    address = doc.search('.section_info table tr')[1].search('td').text.strip

    # course information (another link)

    ski_resort = {
      name: ,
      prefecture:,
      address:,
      # trail_length: ,
      # longest_trial: ,
      # skiable_terrain: ,
      # number_of_trails: ,
      # vertical_drop: ,
      # lift: ,
      # gondola: ,
      # base_altitude: ,
      # highest_altitude: ,
      # steepest_gradient: ,
      # difficulty_green: ,
      # difficulty_red: ,
      # difficulty_black: ,
      # terrain_park:
    }
    p ski_resort
    doc
  end

end
