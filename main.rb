require 'rubygems'
require 'httparty'
require 'open-uri'
require 'json'

# require 'json'

# response = HTTParty.get('https://api.unsplash.com/search/photos?page=1&query=snorkle&client_id=4f64410d0f89accae239cbb1fa2adaf4d0e8fd995d4349fc3136ae9fb9a027f9')

# puts response.body, response.code, response.message, response.headers.inspect

class Unsplashed
	include HTTParty
	attr_reader :options

	base_uri 'https://api.unsplash.com'
		
	def initialize
    api_key  = "4f64410d0f89accae239cbb1fa2adaf4d0e8fd995d4349fc3136ae9fb9a027f9"
    @options = {
      query: {
      	page: "1",
        per_page: "30",
        query: "dog",
        client_id: api_key
      		}
    	}
    @collection =[]
  	end

	def get_data
		data = self.class.get('/search/photos', @options)
		# p data.class
		total_count = data.headers["x-total"]
		body = JSON.parse(data.body)

			download_url = body["results"]

			download_url.each {|hash| 
				@collection << hash["links"]["download"] 
			}
	end

	def download_image
		get_data
		@collection.each_with_index { |down, index|
  		open("#{down}") {|f|
   		File.open("#{index}new.jpg","wb") do |file|
     	file.puts f.read end
     	}
     }
	end

end

unsplash = Unsplashed.new

unsplash.download_image

# p download_location


