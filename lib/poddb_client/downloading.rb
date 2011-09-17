require 'yaml'
require 'uri'

class PoddbClient
  module Downloading

    MEDIA_PLAYER = if `which mplayer` =~ /mplayer/
                     'mplayer'
                   elsif ENV['PODDB_MEDIA_PLAYER'] 
                     ENV['PODDB_MEDIA_PLAYER']
                   elsif RUBY_PLATFORM =~ /darwin/i
                     # This fallback with open iTunes on OS X 
                     'open'
                   else
                     nil
                   end

    def titleize(s, maxlength=20) 
      s.gsub(/\W+/, '-')[0,maxlength].sub(/-$/, '').sub(/^-/, '')
    end

    def download(item_id)
      puts "Downloading podcast item #{item_id}"
      response = `curl -s #{SERVER}/item/#{item_id}/download`
      data = YAML::load(response)
      item = data[:item]
      podcast = data[:podcast]
      enclosure_url = item[:enclosure_url]
      title_fragment = titleize item[:title], 50
      podcast_fragment = titleize podcast[:title], 40

      filename_suffix = File.extname(URI.parse(enclosure_url).path)

      @filename = "%s.%s.poddb_%d_%d%s" % [podcast_fragment, title_fragment, podcast[:podcast_id], item_id, filename_suffix]
      puts "Downloading #{enclosure_url} as #{@filename}"
      cmd = "wget -O #{@filename} '#{enclosure_url}' && touch #{@filename}"
      `#{cmd}`
    end

    def download_marked_items
      download_list_file = "#{CACHE_DIR}/download_list" 
      return unless File.size?(download_list_file)
      item_ids = File.readlines(download_list_file).
        map {|line| line[/(\d+)\s*$/, 1]}.
        compact.map {|x| x.to_i}
      item_ids.each do |item_id| 
        download item_id
      end
    end


    def download_and_play?
      File.size? DOWNLOAD_AND_PLAY_FILE
    end

    def download_and_play
      item_id = File.read(DOWNLOAD_AND_PLAY_FILE).strip
      abort("No item id found") if item_id !~ /\d/
      download item_id
      if MEDIA_PLAYER
        exec("#{MEDIA_PLAYER} #@filename")
      else
        puts "No media player found to play the file!"
      end
    end
  end
end


