require 'yaml'
require 'uri'

class PoddbClient
  module Downloading


    def titleize(s, maxlength=20) 
      s.gsub(/\W+/, '-')[0,maxlength].sub(/-$/, '')
    end

    def download(item_id)
      response = `curl -s #{SERVER}/item/#{item_id}/download`
      data = YAML::load(response)
      item = data[:item]
      podcast = data[:podcast]
      enclosure_url = item[:enclosure_url]
      title_fragment = titleize item[:title], 50
      podcast_fragment = titleize podcast[:title], 40

      filename_suffix = File.extname(URI.parse(enclosure_url).path)

      @filename = "%s.%s.poddb%s%s" % [podcast_fragment, title_fragment, item_id.to_s, filename_suffix]
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
      media_player_cmd = ENV['PODDB_MEDIA_PLAYER'] || 'mplayer'
      exec("#{media_player_cmd} #@filename")
    end
  end
end


