namespace :sns_scraper do
  desc "Scrape all resorts"
  task scrape_all: :environment do

    puts "Getting all the ids"
    list = Sns::GetId.call

    puts "There are a total of #{list.count} resorts"

    list.each do |id|
      # seconds = rand(5..10)
      # puts "sleeping for #{seconds} seconds"
      # sleep(seconds)
      puts "scraping Resort id #{id}"
      Sns::ResortScrapper.call(id)
    end

    puts "Completed sns_scrape_all task"
  end
end
