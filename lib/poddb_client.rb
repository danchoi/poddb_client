require 'poddb_client/downloading'
require 'cgi'
require 'optparse'
require 'net/http'

class PoddbClient

  # TODO: change to poddb.com
  SERVER = "http://localhost:3000"

  CACHE_DIR = "%s/.poddb/cache" % ENV['HOME']
  `mkdir -p #{CACHE_DIR}`

  VIMSCRIPT = "lib/interactive.vim"
  ITEM_LIST_OUTFILE = "#{CACHE_DIR}/main.itemlist"
  PODCAST_LIST_OUTFILE = "#{CACHE_DIR}/main.podcastlist"

  include PoddbClient::Downloading

  def initialize(args)
    @args = args
    @options = {}
    @outfile = ITEM_LIST_OUTFILE # changed only for podcast list
    parse_options
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: poddb [options]"
      opts.separator ""
      opts.on("-A", "--all-recent", "Show all recent podcast items") do 
        @all_recent = true
      end
      opts.on("-f", "--from-podcasts FILE", "Show all recent items from podcasts in FILE") do |file|
        @from_podcasts_file = file
      end
      opts.on("-a", "--add PODCAST_URL", "Add podcast with PODCAST_URL to the poddb database") do |podcast_url|
        @add_podcast = podcast_url
      end
      opts.on("-l", "--list", "List add podcasts in the poddb database") do 
        @list_podcasts = true
      end
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!(@args)
  end

  def run
    if @add_podcast
      add_podcast
    elsif @list_podcasts
      list_podcasts
      interactive
    elsif @from_podcasts_file
      from_podcasts
      interactive
    elsif @all_recent
      all_recent
    else
      search
      interactive
    end
  end

  def add_podcast
    puts "Adding podcast..."
    res = Net::HTTP.post_form(URI.parse("#{SERVER}/podcasts"),
                              'url' => @add_podcast)
    # TODO improve response
    puts res.body
  end

  def interactive
    if !STDOUT.tty?
      puts @output
      exit
    end
    File.open(@outfile, 'w') {|f| f.puts @output}
    cmd = "vim -S #{VIMSCRIPT} #{@outfile} #{@poddb_env}"
    puts cmd
    system(cmd)
    download_marked_items
    cleanup
  end

  def from_podcasts
    podcast_ids = File.readlines(@from_podcasts_file).map {|x| x[/(\d+)\s*$/,1]}.compact.join(',')
    @output = `curl -s #{SERVER}/items?podcast_ids=#{podcast_ids}`
  end

  def list_podcasts
    @outfile = PODCAST_LIST_OUTFILE
    @output = `curl -s #{SERVER}/podcasts`
  end

  def all_recent
    puts 'all recent'
  end

  def search
    query = @args.join(' ')
    @output = `curl -s #{SERVER}/search?q=#{CGI::escape(query)}`
  end

  def cleanup
    `rm -rf #{CACHE_DIR}/*`
  end

end
