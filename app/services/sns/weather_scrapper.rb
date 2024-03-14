class Sns::WeatherScrapper < ApplicationService
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
    @weather_url = "#{ENV.fetch('SNS_URL')}guide/htm/#{@id}#{@suffix[:weather]}.htm"
  end

  def call
    doc = Nokogiri::HTML(URI.open(@weather_url))

    # scrape weather forecast data
    weather_data = doc.search('#weather .SingleLine').map {|x| x.children.children.to_a.map {|x| x.text}.reject(&:empty?)}

    # Obtain date by exclude the first element which is the header "日付"
    dates = weather_data[0][1..-1]

    weather_result = dates.map.with_index do |date, index|
      # Each attr[0] is the key, and respective value is index + 1 because dates poped the first value
      Hash[weather_data.map { |attr| [attr[0], attr[index + 1]] }]
    end

    p weather_result

    # scrape snow quality data
    snow_data = doc.search('#snow .SingleLine').map {|x| x.children.children.to_a.map {|x| x.text}.reject(&:empty?)}

    # Obtain date by exclude the first element which is the header "日付"
    dates = snow_data[0][1..-1]

    snow_result = dates.map.with_index do |date, index|
      # Each attr[0] is the key, and respective value is index + 1 because dates poped the first value
      Hash[snow_data.map { |attr| [attr[0], attr[index + 1]] }]
    end

    p snow_result
  end
end
