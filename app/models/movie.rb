class Movie < ActiveRecord::Base
  def self.all_ratings
    Movie.all.map{|movie| movie.rating}.uniq.sort
  end
end
