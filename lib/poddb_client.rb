require 'poddb_client/downloading'
require 'cgi'
require 'optparse'
require 'net/http'

class PoddbClient

  # TODO: change to poddb.com
  SERVER = "http://localhost:3000"

  CACHE_DIR = "%s/.poddb/cache" % ENV['HOME']
  `mkdir -p #{CACHE_DIR}`

  include PoddbClient::Downloading

  def initialize(args)
    @args = args
    @options = {}
    parse_options
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: poddb [options]"
      opts.separator ""

      opts.on("-a", "--add PODCAST_URL", "Add podcast with PODCAST_URL to the poddb database") do |podcast_url|
        @options[:add_podcast] = podcast_url
      end
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!(@args)
  end

  def run
    if @options[:add_podcast]
      add_podcast
    else
      search
    end
  end

  def add_podcast
    puts "Adding podcast..."
    res = Net::HTTP.post_form(URI.parse("#{SERVER}/podcasts"),
                              'url' => @options[:add_podcast])
    
    puts res.body
  end

  def search
    query = @args.join(' ')
    output = `curl -s #{SERVER}/search?q=#{CGI::escape(query)}`
    vimscript = "lib/interactive.vim"
    outfile = "#{CACHE_DIR}/main.itemlist"
    File.open(outfile, 'w') {|f| f.puts output}
    system("vim -S #{vimscript} #{outfile}")
    download_marked_items
    cleanup
  end

  def cleanup
    `rm -rf #{CACHE_DIR}/*`
  end

  def list_podcasts
    # TODO 
    # list podcasts
    # /podcasts
    # just print to STDOUT
  end

end
