require 'nokogiri'
require 'open-uri'

module Sns
  class GetId < ApplicationService
    def initialize
      @url = "#{ENV.fetch('SNS_URL')}/search/list/spl_area01.php?areacdl="
      @range = (1..7)
    end

    def call
      list = []
      @range.each do |n|
        base_url = @url + n.to_s
        doc = Nokogiri::HTML(URI.open(base_url))
        list += scrap(doc)

        # check if there are multiple pages
        nav_bar = doc.search('.page_nav a')[-2]

        # return list of ids if there is only one page
        return list unless nav_bar

        # repeat scrapper if there are more than 1 page
        last_page = nav_bar.values.first.gsub(/\D/, '').to_i
        (2..last_page).each do |page|
          url = base_url + "&page=#{page}"
          doc = Nokogiri::HTML(URI.open(url))
          list += scrap(doc)
        end
      end
      list
    end

    private

    def scrap(doc)
      doc.search('.list_result h2 a').to_a.map{ |x| x.attribute_nodes[0].value[%r{/htm/(.*?)s\.htm}, 1] }
    end
  end
end
