require 'poddb_client/downloading'
require 'poddb_client/version'
require 'cgi'
require 'optparse'
require 'net/http'

class PoddbClient

  # TODO: set for production
  SERVER = ENV['PODDB_SERVER'] || "http://poddb.com"

  PODDB_DIR = "%s/.poddb" % ENV['HOME']
  CACHE_DIR = "%s/.poddb/cache" % ENV['HOME']
  `mkdir -p #{CACHE_DIR}`

  VIMSCRIPT = File.join(File.expand_path(File.dirname(__FILE__)), 'interactive.vim')
  ITEM_LIST_OUTFILE = "#{CACHE_DIR}/main.itemlist"
  PODCAST_LIST_OUTFILE = "#{CACHE_DIR}/main.podcastlist"
  FAVORITE_PODCASTS_FILE = "#{PODDB_DIR}/favorites"
  DOWNLOAD_AND_PLAY_FILE = "#{CACHE_DIR}/download_and_play"

  include PoddbClient::Downloading

  def initialize(args)
    @args = args
    @options = {}
    @params = ["v=#{PoddbClient::VERSION}" ]
    @outfile = ITEM_LIST_OUTFILE # changed only for podcast list
    @version = PoddbClient::VERSION
    @query = []
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
      opts.on("-l", "--list [QUERY]", "List all podcasts in the poddb database", "(If QUERY is supplied, will return matching podcasts)") do |query|
        @list_podcasts = true
        if query
          @query << query
        end
      end
      opts.on("-F", "--favorite-podcasts", "Show favorite podcasts") do
        if ! File.size?(FAVORITE_PODCASTS_FILE)
          puts "No podcasts found in #{FAVORITE_PODCASTS_FILE}"
          exit
        end
        @list_favorite_podcasts = true
      end
      opts.on("-o", "--order ORDER", "Sort results by ORDER", "The only option right now is 'popular'. Default order is pubdate.") do |order|
        @params << "o=#{order}"
      end
      opts.on("-d", "--days DAYS", "Limit results to items published since DAYS days ago") do |days|
        @params << "d=#{days}"
      end
      opts.on("-t", "--type MEDIA_TYPE", "Return items of MEDIA_TYPE only (audio,video)") do |media_type|
        @params << "t=#{media_type}"
      end
      opts.on("--download-and-play ITEM_ID", "Download item and play with PODDB_MEDIA_PLAYER") do |item_id|
        puts "Download and play #{item_id}"
      end
      opts.on("--readme", "Show README") do
        readme_file = File.expand_path("../../README.markdown", __FILE__)
        system("less #{readme_file}")
        exit
      end
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        puts 
        puts "For more detailed help, use `poddb --readme` or visit http://danielchoi.com/software/poddb.html"
        exit
      end
      opts.on_tail("-v", "--version", "Show version number") do
        puts "poddb #{VERSION}"
        exit
      end
    end.parse!(@args)
    @query = @query.concat @args
    q = CGI::escape(@query.join(' ').strip)
    if q != '' 
      @params << "q=#{q}"
    end
    @params = @params.empty? ? '' : @params.join('&')
  end

  def run
    cleanup
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
    puts "Adding podcast with url: #{@add_podcast}"
    res = Net::HTTP.post_form(URI.parse("#{SERVER}/podcasts"), 'url' => @add_podcast).body
    if res =~ /^Error/
      puts res
    else
      podcast_id, title = res.split(/\s+/, 2)
      add_to_favorite_podcasts(podcast_id, title)
    end
  end

  def interactive
    if !STDOUT.tty?
      puts @output
      exit
    end
    if @output =~ /^No matches/i || @output =~ /^Error/
      puts @output
      exit
    end
    File.open(@outfile, 'w') {|f| f.puts @output }
    cmd = "export PODDB_SERVER=#{SERVER} && vim -S #{VIMSCRIPT} #{@outfile} "
    system(cmd)
    if download_and_play?
      download_and_play
    else
      download_marked_items
    end
    cleanup
  end

  def list_podcasts
    @outfile = PODCAST_LIST_OUTFILE
    @output = if @list_podcasts
                `curl -s '#{SERVER}/podcasts?#@params'`
              elsif @list_favorite_podcasts 
                `curl -s '#{SERVER}/podcasts?podcast_ids=#{favorite_podcast_ids.join(',')}'`
              end
    if File.size?(FAVORITE_PODCASTS_FILE)
      @output = @output.split("\n").map {|line|
        # podcast_ids here are strings
        if (podcast_id = line[/\d+$/,0]) && favorite_podcast_ids.detect{|i| i.to_s == podcast_id}
          line.sub(/^ /, "@")
        else
          line
        end
      }.join("\n")
    end
  end

  def items_from_favorites
    @output = `curl -s '#{SERVER}/items?podcast_ids=#{favorite_podcast_ids.join(',')}&#@params'`
    mark_already_downloaded
  end

  def search
    @output = `curl -s '#{SERVER}/search?#@params'`
    mark_already_downloaded
  end

  def cleanup
    `rm -rf #{CACHE_DIR}/*`
  end

private

  def favorite_podcast_ids
    if File.size?(FAVORITE_PODCASTS_FILE)
      File.readlines(FAVORITE_PODCASTS_FILE).map(&:strip).select {|x| x =~ /\d+/}.map {|x| x.to_i}
    else
      []
    end
  end

  def add_to_favorite_podcasts(podcast_id, title)
    if File.size?(FAVORITE_PODCASTS_FILE) && File.read(FAVORITE_PODCASTS_FILE).split("\n").any? {|line| line.strip == podcast_id.to_s}
      puts "'#{title}' [##{podcast_id}] is already in your favorite podcasts. Type `poddb -F` to show your favorites."
      return
    end
    if podcast_id !~ /\d/
      puts "Error: No podcast detected for #{podcast_id}"
      return
    end
    podcast_id = podcast_id.to_i
    File.open(FAVORITE_PODCASTS_FILE, 'a') {|f|
      f.puts podcast_id
    }
    puts "Added '#{title}' [##{podcast_id}] to your favorite podcasts. Type `poddb -F` to show your favorites."
  end

  def mark_already_downloaded
    @downloaded_item_ids = Dir['*poddb_*'].map { |f| f[/poddb_\d+_(\d+)/,1] }.compact
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
