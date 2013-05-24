require 'ostruct'

class SitemapChecker

  def initialize(options={})
    @options = OpenStruct.new(options)
    @errors = []
  end

  def check
    @errors = []

    xml = fetch_sitemap(@options.domain)
    urls, images = parse_sitemap(xml)
    urls.concat(images)

    write "#{urls.length} urls and #{images.length} images found in sitemap.xml."
    write "Beginning status code check..."

    urls.each do |url|
      check_url(url)
      sleep @options.delay
    end

    if @errors.length > 0
      write "*** urls not working: ***"
      @errors.each { |err| write "HTTP #{err.status_code} - #{err.url}" }
    else
      write "*** all urls in sitemap.xml are working ***"
    end
  end

  def check_url(url)
    write "Checking #{url}..."
    status_code = get_status(url)
    if status_code >= 400
      @errors << { status_code: status_code, url: url }
    end
  end

  def get_status(url)
    HTTParty.get(url).code
  end

  private

  def write(s)
    puts "  " + s
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
      url["loc"].each do |loc|
        urls << loc
      end
      url["image"].each do |image|
        image["loc"].each do |loc|
          images << loc
        end
      end
    end

    return urls, images
  end

end