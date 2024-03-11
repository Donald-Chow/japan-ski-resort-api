require 'nokogiri'
require 'open-uri'

class Sns::ResortScrapper < ApplicationService
  def initialize(id)
    @suffix = {
      weather: 'we',
      reviews: 'rvl',
      information: 'r',
      pickup: 'pu',
      course: 'gc1',
      snowpark: 'gp',
      kidspark: 'kp',
      video: 'mv',
      gallery: 'rvp',
      ticket: 'tk',
      fee: 'gc2',
      coupon: 'c',
      school: 'gs',
      event: 'e',
      restaurant: 'gf',
      facilities: 'fa',
      access: 'm'
    }
    @id = id ## change to variable
    @url = "https://surfsnow.jp/guide/htm/#{@id}s.htm"
    @weather_url = "https://surfsnow.jp/guide/htm/#{@id}#{@suffix[:weather]}.htm"
    @course_url = "https://surfsnow.jp/guide/htm/#{@id}#{@suffix[:course]}.htm"
  end

  def call
    # scrapping base webpage
    doc = Nokogiri::HTML(URI.open(@url))
    name = doc.search(".site_title p").children.first.text.strip
    prefecture = doc.search(".site_title p small").text.strip
    address = doc.search('.section_info table tr')[1].search('td').text.strip
    picture = doc.search('.section_info_image img').first
    picture_url = "https://surfsnow.jp/" + picture.attribute_nodes.select {|node| node.name == 'src'}.first.value if picture

    begin # guard against 404
      # scrapping course information (another link)
      c_doc = Nokogiri::HTML(URI.open(@course_url))

      # formatting course data
      course_data = c_doc.search('#CourseDataBox .right dl').text.lines.map(&:strip).compact_blank.each_slice(2).to_h

      # format altitude data
      altitude_data = course_data['標高'].split.map { |x| x.gsub(/\D/, '').to_i }

      base_altitude = altitude_data[1]
      highest_altitude = altitude_data[0]
      vertical_drop = altitude_data[2]

      # format lift data
      lift_data_array = course_data['リフト数'].split.map do |x|
        matches = x.match(/(.*?)(\d+)/)
        [matches[1], matches[2]]
      end
      lift_data = lift_data_array.to_h.transform_values(&:to_i)

      # scrapping lift data
      gondola = lift_data.delete('ゴンドラ')
      lift = lift_data.values.sum

      # formatting difficulty data
      difficulty_data_array = c_doc.search("#Technique tbody tr td").map do |element|
        element.attribute_nodes.map(&:value)
      end
      dfficulty_data = difficulty_data_array.to_h { |key, value| [value, key] }

      # scrapping difficulty data
      difficulty_green = dfficulty_data['level01']
      difficulty_red = dfficulty_data['level02']
      difficulty_black = dfficulty_data['level03']

      # scraping trail data
      trail_length = c_doc.search('#course').text.scan(/\d{1,3}(?:,\d{3})*m/).map { |x| x.gsub(/\D/, '').to_i }.sum
      number_of_trails = course_data['コース数'].gsub(/\D/, '').to_i
      longest_trial = course_data['最長滑走距離'].match(/\d{1,3}(?:,\d{3})*m/).to_s.gsub(/\D/, '').to_i
      steepest_gradient = course_data['最大斜度'].gsub(/\D/, '').to_i

      # getting the pictures
      course_map = c_doc.search('#CourseMap img').first
      course_map_url ="https://surfsnow.jp/" + course_map.attribute_nodes.select {|node| node.name == 'src'}.first.value if course_map
    rescue StandardError => e
      puts "Error: #{e.message}"
    end
    # setting the data into params
    params = {
      name:,
      prefecture:,
      address:,
      trail_length:,
      longest_trial:,
      number_of_trails:, # rescrape
      vertical_drop:, # calculate
      lift:, # rescrape
      gondola:, # rescrape??
      base_altitude:, # rescrape
      highest_altitude:, # rescrape
      steepest_gradient:,
      difficulty_green:, # rescrape
      difficulty_red:, # rescrape
      difficulty_black:, # rescrape
      picture_url:,
      course_map_url:
      # skiable_terrain: , #course
      # terrain_park: #course
    }
    resort = Resort.find_or_initialize_by(sns_id: @id)
    resort.update(params)
  end
end
