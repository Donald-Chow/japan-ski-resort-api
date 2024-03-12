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
    @base_url = "https://surfsnow.jp/"
    @main_url = "#{@base_url}guide/htm/#{@id}s.htm"
    @weather_url = "#{@base_url}guide/htm/#{@id}#{@suffix[:weather]}.htm"
    @course_url = "#{@base_url}guide/htm/#{@id}#{@suffix[:course]}.htm"
  end

  def call
    # setting the data into params
    puts "Scrapping main info for #{@id}"
    doc = Nokogiri::HTML(URI.open(@main_url))

    params = scrape_main_info(doc)

    begin
      puts "Scrapping course info from course page for #{@id}"
      c_doc = Nokogiri::HTML(URI.open(@course_url))
      # scrapping course information (another link)
      course_params = scrap_course_page(c_doc)
    rescue StandardError => e
      puts "Error: #{e.message}"
      puts "Scrapping course info from main page instead for #{@id}"
      # scrapping course info on main page
      course_params = scrape_course_on_main_page(doc)
    end

    # merge results into one parms
    params = params.merge(course_params)
    # params = {
    #   name:,
    #   prefecture:,
    #   address:,
    #   trail_length:,
    #   longest_trial:,
    #   number_of_trails:, # rescrape
    #   vertical_drop:, # calculate
    #   lift:, # rescrape
    #   gondola:, # rescrape??
    #   base_altitude:, # rescrape
    #   highest_altitude:, # rescrape
    #   steepest_gradient:,
    #   difficulty_green:, # rescrape
    #   difficulty_red:, # rescrape
    #   difficulty_black:, # rescrape
    #   picture_url:,
    #   course_map_url:
    #   # skiable_terrain: , #course
    #   # terrain_park: #course
    # }
    resort = Resort.find_or_initialize_by(sns_id: @id)
    resort.update(params)
  end

  def scrape_main_info(doc)
    # scrapping main webpage
    name = doc.search(".site_title p").children.first.text.strip
    prefecture = doc.search(".site_title p small").text.strip
    address = doc.search('.section_info table tr')[1].search('td').text.strip
    picture = doc.search('.section_info_image img').first
    if picture
      picture_url = @base_url + picture.attribute_nodes.select { |node| node.name == 'src' }.first.value
    else
      logo_url = doc.search('.site_title img').first.attribute_nodes.select { |node| node.name == 'src' }.first.value
      picture_url = @base_url + logo_url
    end
    return { name:, prefecture:, address:, picture_url: }
  end

  def scrape_course_on_main_page(doc)
    # scrapping main info box
    unless doc.search("h3.high") == []
      highest_altitude = doc.search("h3.high").text.match(/\d{1,3}(?:,\d{3})*m/).to_s.gsub(/\D/, '').to_i
      base_altitude = doc.search("h3.base").text.match(/\d{1,3}(?:,\d{3})*m/).to_s.gsub(/\D/, '').to_i
    end

    # scrapping course guide on the top
    course_data = doc.search(".course dl").children.text.split("\n").reject!(&:empty?)
    unless course_data == [] || course_data.nil?
      course_data = course_data.each_slice(2).to_h
      number_of_trails = course_data['コース数']&.to_i
      steepest_gradient = course_data['最大斜度']&.to_i
      longest_trial = course_data['最長滑走距離'].gsub(/\D/, '').to_i if course_data['最長滑走距離']
    end

    # formatting difficulty data
    difficulty_data = doc.search(".course td").to_h { |x| x.attribute_nodes.map(&:value) }
    # scrapping difficulty data
    difficulty_green = difficulty_data['color01'].to_i
    difficulty_red = difficulty_data['color02'].to_i
    difficulty_black = difficulty_data['color03'].to_i

    # scrapping bottom info box
    section_info = doc.search('.section_info tr').to_h { |x| x.children.map(&:text) }

    # Looking for course info
    if section_info['コース情報']
      course_info = section_info['コース情報'].split.to_h { |x| x.split('：') }
      lift = course_info['リフト本数'].gsub(/\D/, '').to_i if course_info['リフト本数']
    end

    # build result
    hash = {}
    hash[:number_of_trails] = number_of_trails if number_of_trails
    hash[:lift] = lift if lift
    hash[:base_altitude] = base_altitude if base_altitude
    hash[:highest_altitude] = highest_altitude if highest_altitude
    hash[:vertical_drop] = highest_altitude - base_altitude if highest_altitude && base_altitude
    hash[:difficulty_green] = difficulty_green if difficulty_green
    hash[:difficulty_red] = difficulty_red if difficulty_red
    hash[:difficulty_black] = difficulty_black if difficulty_black
    hash[:steepest_gradient] = steepest_gradient if steepest_gradient
    hash[:longest_trial] = longest_trial if longest_trial

    hash
  end

  def scrap_course_page(c_doc)
    # formatting course data
    course_data = c_doc.search('#CourseDataBox .right dl').to_a.map{|x|x.children.text.strip.split("\n")}.to_h{|key, value| [key, value ? value : ""]}

    # format altitude data
    if course_data['標高']
      altitude_data = course_data['標高'].split.map { |x| x.gsub(/\D/, '').to_i }

      base_altitude = altitude_data[1]
      highest_altitude = altitude_data[0]
      vertical_drop = altitude_data[2]
    end

    # format lift data
    if course_data['リフト数']
      lift_data_array = course_data['リフト数'].split.map do |x|
        matches = x.match(/(.*?)(\d+)/)
        [matches[1], matches[2]]
      end
      lift_data = lift_data_array.to_h.transform_values(&:to_i)
      gondola = lift_data.delete('ゴンドラ')
      lift = lift_data.values.sum
    end

    # scrapping lift data

    # formatting difficulty data
    difficulty_data_array = c_doc.search("#Technique tbody tr td").map do |element|
      element.attribute_nodes.map(&:value)
    end
    difficulty_data = difficulty_data_array.to_h { |key, value| [value, key] }

    # scrapping difficulty data
    difficulty_green = difficulty_data['level01'].to_i
    difficulty_red = difficulty_data['level02'].to_i
    difficulty_black = difficulty_data['level03'].to_i

    # scraping trail data
    trail_length = c_doc.search('#course').text.scan(/\d{1,3}(?:,\d{3})*m/).map { |x| x.gsub(/\D/, '').to_i }.sum
    number_of_trails = course_data['コース数'].gsub(/\D/, '').to_i if course_data['コース数']
    longest_trial = course_data['最長滑走距離'].match(/\d{1,3}(?:,\d{3})*m/).to_s.gsub(/\D/, '').to_i if course_data['最長滑走距離']
    steepest_gradient = course_data['最大斜度'].gsub(/\D/, '').to_i if course_data['最大斜度']

    # getting the pictures
    course_map = c_doc.search('#CourseMap img').first
    if course_map
      course_map_extension = course_map.attribute_nodes.select { |node| node.name == 'src' }.first.value
      course_map_url = @base_url + course_map_extension
    end

    # build result
    hash = {}
    hash[:base_altitude] = base_altitude if base_altitude
    hash[:highest_altitude] = highest_altitude if highest_altitude
    hash[:vertical_drop] = vertical_drop || (highest_altitude - base_altitude if highest_altitude && base_altitude)
    hash[:gondola] = gondola if gondola
    hash[:lift] = lift if lift
    hash[:difficulty_green] = difficulty_green if difficulty_green
    hash[:difficulty_red] = difficulty_red if difficulty_red
    hash[:difficulty_black] = difficulty_black if difficulty_black
    hash[:trail_length] = trail_length if trail_length
    hash[:number_of_trails] = number_of_trails if number_of_trails
    hash[:longest_trial] = longest_trial if longest_trial
    hash[:steepest_gradient] = steepest_gradient if steepest_gradient
    hash[:course_map_url] = course_map_url if course_map_url

    return hash
  end
end
