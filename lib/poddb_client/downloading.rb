require 'yaml'
require 'uri'

class PoddbClient
  module Downloading
    def titleize(s, maxlength=20) 
      s.gsub(/\W+/, '_')[0,maxlength].sub(/_$/, '')
    end

    def download(item_id)
      response = `curl -s #{SERVER}/item/#{item_id}/download`
      data = YAML::load(response)
      item = data[:item]
      podcast = data[:podcast]
      enclosure_url = item[:enclosure_url]
      title_fragment = titleize item[:title], 40
      podcast_fragment = titleize podcast[:title], 30

      filename_suffix = File.extname(URI.parse(enclosure_url).path)

      filename = "%s.%s.poddb_%s%s" % [podcast_fragment, title_fragment, item_id.to_s, filename_suffix]
      puts "Downloading #{enclosure_url} as #{filename}"
      cmd = "wget -O #{filename} '#{enclosure_url}' && touch #{filename}"
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
  end
end


