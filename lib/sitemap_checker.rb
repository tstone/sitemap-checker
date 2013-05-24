require 'ostruct'

class SitemapChecker

  def initialize(options={})
    @options = OpenStruct.new(options)
  end

  def check
    reset

    xml = fetch_sitemap(@options.domain)
    @urls, @images = parse_sitemap(xml)
    urls = @urls.concat(@images)

    write "#{@urls.length} urls and #{@images.length} images found in sitemap.xml."
    write "Beginning status code check..."

    @total_time = Benchmark.realtime do
      urls.each_with_index do |url, i|
        check_url(url)

        avg_response = @response_times.reduce(0) { |acc, time| acc + time } / @response_times.length
        remaining = urls.length - i
        remaining_time = (avg_response * remaining) + (@options.delay * remaining)
        remaining_time = format_time(remaining_time)
        write "Estimated time remaining: #{remaining_time}"
        sleep @options.delay
      end
    end

    write_stats
  end

  def check_url(url)
    
    write ""
    write "Checking #{url}..."
    
    status_code = nil
    time = Benchmark.realtime { status_code = get_status(url) }
    write "HTTP #{status_code} in #{time.round(2)} seconds"
    @response_times << time

    if status_code >= 400
      @errors << { status_code: status_code, url: url }
    end
  end

  def get_status(url)
    HTTParty.get(url).code
  end

  private

  def format_time(seconds)
    time = (Time.mktime(0)+seconds).strftime("%Hh %Mm %Ss")
    time = time.sub("00h ", "")
    time = time.sub("00m ", "")
    return time
  end

  def reset
    @errors = []
    @response_times = []
    @image_count = []
    @no_images = 0
  end

  def write(s)
    puts "  " + s
  end

  def write_stats
    write ""
    write "----------------------------------------------"
    write ""
    
    if @errors.length == 0
      write "All URLs respond successfully"
    else
      write "Errors:"
      @errors.each { |err| write "HTTP #{err.status_code} - #{err.url}" }
    end

    write ""
    write "#{@urls.length} urls and #{@images.length} images fetched in #{@total_time.round(2)} seconds"

    avg_response = @response_times.reduce(0) { |acc, time| acc + time } / @response_times.length
    write "Average Response: #{avg_response.round(2)} seconds"
  end

  def fetch_sitemap(domain)
    sitemap_url = "http://#{domain}/sitemap.xml"
    write "Fetching #{sitemap_url}..."
    HTTParty.get(sitemap_url).body
  end

  def parse_sitemap(xml)
    sitemap = ::XmlSimple.xml_in(xml)
    urls = []
    images = []

    sitemap["url"].each do |url|
      if url.has_key?("loc")
        url["loc"].each do |loc|
          urls << loc
        end
      end
      if url.has_key?("image")
        url["image"].each do |image|
          if image.has_key?("loc")
            @image_count << image["loc"].length
            image["loc"].each do |loc|
              images << loc
            end
          end
        end
      else
        @no_images += 1
      end
    end

    return urls, images
  end

end