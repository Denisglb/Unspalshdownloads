require 'rubygems'
require 'httparty'
require 'open-uri'
require 'json'
require 'active_support/time'
require "yaml"

class Unsplashed
	include HTTParty
	attr_reader :options

	base_uri 'https://api.unsplash.com'

	def initialize
		@apikey = YAML::load_file('config.yml')["apikey"]
    	@collection =[]
    	@page_count = 0
    	@total = 0
    	@count = 0
  	end

	def page_count(query)
		data = self.class.get('/search/photos', options(query, 1))
		if (data.headers["x-total"].to_i / 30) == 0
			@page_count =1
		else
			@page_count = (data.headers["x-total"].to_i / 30)
		end
		p "Number of pages = " + (@page_count).to_s
		p "Number of photos to download = " + data.headers["x-total"]
		@total = data.headers["x-total"].to_i
		p "Number of hours = " + (@page_count/45).to_s
	end

	def controller(query)
		page_count(query)
		Dir.mkdir "./#{query}"
		for i in (1..@page_count.to_i)
			if i%45 == 0
				sleep(1.hours)
			end
			begin
				get_data(query, i)
				download_images(query, i)
				@collection = []
			rescue OpenURI::HTTPError => e
  				if e.message == '404 Not Found'
  					@collection =[]
  					p "oops, there was an error on page #{i}. skipping this to page #{i + 1} :)"
  					i += 1
  					retry
  				else
  					raise e
  				end
			end
		end
	end

	def get_data(query, page)
		data = self.class.get('/search/photos', options(query, page))
		if (@count > 0 && @count%45 == 0)
			p "It's time for me take a break, I am tired and I have a life too you know!"
		end
		@count +=1
		p "Getting all photos from page " + @count.to_s
		body = JSON.parse(data.body)
		download_url = body["results"]
		download_url.each {|hash| 
			@collection << hash["links"]["download"] 
		}
	end

	def options(query, page)
		{query: {
	      	page: page,
	        per_page: "30",
	        query: query,
	        client_id: @apikey
      		}
    	}
	end

	def download_images(query, number)
		@collection.each_with_index { |down, index|
  		open("#{down}") {|f|
   		File.open("./#{query}/Page #{number} Image #{index+1} of #{query}.jpg","wb")  do |file|
     	file.puts f.read end
     	}
     }
	end
end

# EXAMPLE of how to run the script to get all photos of "cats" :) Just change the name of what images you want and it will download them to this file. 
unsplash = Unsplashed.new
unsplash.controller("skin")