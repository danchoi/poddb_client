require 'poddb_client/downloading'
require 'cgi'
require 'optparse'
require 'net/http'

class PoddbClient

  # TODO: change to poddb.com
  SERVER = "http://localhost:3000"

  PODDB_DIR = "%s/.poddb" % ENV['HOME']
  CACHE_DIR = "%s/.poddb/cache" % ENV['HOME']
  `mkdir -p #{CACHE_DIR}`

  VIMSCRIPT = "lib/interactive.vim"
  ITEM_LIST_OUTFILE = "#{CACHE_DIR}/main.itemlist"
  PODCAST_LIST_OUTFILE = "#{CACHE_DIR}/main.podcastlist"
  FAVORITE_PODCASTS_FILE = "#{PODDB_DIR}/favorites"

  include PoddbClient::Downloading

  def initialize(args)
    @args = args
    @options = {}
    @outfile = ITEM_LIST_OUTFILE # changed only for podcast list
    parse_options
  end

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "Usage: poddb [options] [query]"
      opts.separator ""
      opts.on("-f", "--from-favorites", "Show all recent items from favorite podcasts") do
        if ! File.size?(FAVORITE_PODCASTS_FILE)
          puts "No podcasts found in #{FAVORITE_PODCASTS_FILE}"
          exit
        end
        @items_from_favorites = true
      end
      opts.on("-a", "--add PODCAST_URL", "Add podcast with PODCAST_URL to the poddb database") do |podcast_url|
        @add_podcast = podcast_url
      end
      opts.on("-l", "--list", "List all podcasts in the poddb database", "(If query is supplied, will return matching podcasts)") do 
        @list_podcasts = true
      end
      opts.on("-F", "--favorite-podcasts", "Show favorite podcasts") do
        if ! File.size?(FAVORITE_PODCASTS_FILE)
          puts "No podcasts found in #{FAVORITE_PODCASTS_FILE}"
          exit
        end
        @list_favorite_podcasts = true
      end
      opts.on("-t", "--type MEDIA_TYPE", "Return items of MEDIA_TYPE only (audio,video)") do |media_type|
        @media_type_param = "&media_type=#{media_type}"
      end
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!(@args)
    @query = CGI::escape(@args.join(' ').strip)
  end

  def run
    if @add_podcast
      add_podcast
    elsif @list_podcasts || @list_favorite_podcasts 
      list_podcasts
      interactive
    elsif @items_from_favorites
      items_from_favorites
      interactive
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
    if @output =~ /^No matches/i
      puts @output
      exit
    end

    File.open(@outfile, 'w') {|f| f.puts @output }
    cmd = "vim -S #{VIMSCRIPT} #{@outfile} #{@poddb_env}"
    puts cmd
    system(cmd)
    download_marked_items
    cleanup
  end

  def list_podcasts
    @outfile = PODCAST_LIST_OUTFILE
    @output = if @list_podcasts
                `curl -s #{SERVER}/podcasts?q=#{@query}`
              elsif @list_favorite_podcasts 
                `curl -s #{SERVER}/podcasts?podcast_ids=#{favorite_podcast_ids.join(',')}`
              end
    if File.size?(FAVORITE_PODCASTS_FILE)
      @output = @output.split("\n").map {|line|
        # podcast_ids here are strings
        if (podcast_id = line[/\d+$/,0]) && favorite_podcast_ids.include?(podcast_id)
          line.sub(/^ /, "@")
        else
          line
        end
      }.join("\n")
    end
  end

  def items_from_favorites
    @output = `curl -s '#{SERVER}/items?podcast_ids=#{favorite_podcast_ids.join(',')}#{@media_type_param}'`
    mark_already_downloaded
  end

  def search
    @output = `curl -s '#{SERVER}/search?q=#{@query}#{@media_type_param}'`
    mark_already_downloaded
  end

  def cleanup
    `rm -rf #{CACHE_DIR}/*`
  end

private

  def favorite_podcast_ids
    if File.size?(FAVORITE_PODCASTS_FILE)
      File.readlines(FAVORITE_PODCASTS_FILE).map(&:strip).select {|x| x != ''}
    else
      []
    end
  end

  def mark_already_downloaded
    @downloaded_item_ids = Dir['*poddb*'].map { |f| f[/poddb(\d+)/,1] }.compact
    @output = @output.split(/\n/).map {|line| 
      item_id = line[/\d+$/,0] 
      if @downloaded_item_ids.include?(item_id)
        line.sub(/^ /, 'D')
      else
        line
      end
    }.join("\n")
  end


end
