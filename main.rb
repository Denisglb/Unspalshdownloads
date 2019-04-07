require 'rubygems'
require 'httparty'
require 'open-uri'
require 'json'

class Unsplashed
	include HTTParty
	attr_reader :options

	base_uri 'https://api.unsplash.com'
		
	def initialize
    	@api_key  = "4f64410d0f89accae239cbb1fa2adaf4d0e8fd995d4349fc3136ae9fb9a027f9"
    	@collection =[]
    	@page_count = 0
  	end

	def page_count(query)
		data = self.class.get('/search/photos', options(query))
		if (data.headers["x-total"].to_i / 30) == 0
			@page_count =1
		else
			@page_count = (data.headers["x-total"].to_i / 30)
			p @page_count
		end
	end

	def controller(query)
		page_count(query)
		@page_count.to_i.times do |i|
			get_data(query, i)

		end
		download_images(query)
	end

	def get_data(query, page)
		data = self.class.get('/search/photos', options(query))
		body = JSON.parse(data.body)
		download_url = body["results"]
		download_url.each {|hash| 
			@collection << hash["links"]["download"] 
		}
	end

	def options(query, page=1)
		{query: {
	      	page: page.to_s,
	        per_page: "30",
	        query: query,
	        client_id: @api_key
      		}
    	}
	end

	def download_images(query)
		@collection.each_with_index { |down, index|
  		open("#{down}") {|f|
   		File.open("Image #{index + 1} of #{query}.jpg","wb") do |file|
     	file.puts f.read end
     	}
     }
	end
end

# EXAMPLE of how to run the script to get all photos of "cats" :) Just change the name of what images you want and it will download them to this file. 
unsplash = Unsplashed.new
unsplash.controller("cat")




