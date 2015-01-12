# encoding: UTF-8
require 'net/http'
require 'logger'
require 'json'

class Trade
  @@precious_metals_url = 'http://www.xmlcharts.com/cache/precious-metals.php?format=json'
  @@exchange_rate_url = 'http://www.nbg.ge/rss.php'
  def initialize(log)
    @items = %w[gold palladium platinum silver]
    @log = log
  end

  def fetch_precious_metals(curr="usd")
    @log.info('Getting precious metal prices')
    body = Net::HTTP.get(URI.parse(@@precious_metals_url))
    #body = File.read('precious-metals.json')
    @log.info('Got precious metal prices')
    JSON.parse(body)[curr]
  end

  def fetch_exch_rate
    @log.info('Getting exchange rate')
    patt = /<td>1 აშშ დოლარი<\/td>\n\t\t\t<td>(\d+[,.]\d+)<\/td>/
    body = Net::HTTP.get(URI.parse(@@exchange_rate_url))
    m = patt.match(body.force_encoding("UTF-8"))
    if m.nil?
      @log.error('Error getting exchange rate')
    else
      @log.info("Got exchange rate - #{m[1]}")
    end
    m[1].to_f
  end

  def text_feed
    begin
      metals = fetch_precious_metals
      rate = fetch_exch_rate
    rescue Exception => e
      @log.error "There was an error while fetching data: #{e.message}"
      raise
    end

    first_line = Time.now.strftime("%d/%m/%Y") +", kursi: #{rate.round(4)}"
    metal_liens = @items.map do |item|
      pr_usd = metals[item].to_f.round(3)
      pr_gel = (pr_usd * rate).round(3)
      "#{item}: #{pr_usd} (#{pr_gel} GEL)"
    end
    text_lines = [first_line] + metal_liens
    text_lines.join("\n")
  end
end

logfile = File.open('avtofeed.log', File::WRONLY | File::APPEND | File::CREAT)
logger = Logger.new(logfile, 1, 1024000)
t  = Trade.new logger
puts t.text_feed

