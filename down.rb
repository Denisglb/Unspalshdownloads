require 'open-uri'

	def download_image(url)
  		open(url) {|f|
   		File.open("new.jpg","wb") do |file|
     	file.puts f.read end
     }
	end

download_image("https://unsplash.com/photos/zgyLhFAfW-Q/download")