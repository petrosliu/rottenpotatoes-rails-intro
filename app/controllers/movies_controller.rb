class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    
    if !session.has_key?(:sortby)
      session[:sortby]="id"
    end
    
    if !session.has_key?(:rating_filter) || (!params.has_key?(:ratings)&&params.has_key?(:commit))
      session[:rating_filter]=Hash.new(false)
      @all_ratings.each{|rating| session[:rating_filter][rating]=true}
    end
    
    if !params.has_key?(:ratings) || !params.has_key?(:sortby)
      flash.keep
      
      if params.has_key?(:ratings)
        session[:rating_filter]=Hash.new(false)
        params[:ratings].each_key{|rating| session[:rating_filter][rating]=true}
      end
      
      if params.has_key?(:sortby)
        session[:sortby]=params[:sortby]
      end
      
      redirect_to movies_path(:ratings=>session[:rating_filter], :sortby=>session[:sortby])
    end
    
    @rating_filter = Hash.new(false)
    if params.has_key?(:ratings)
      curr_ratings=[]
      params[:ratings].each_key do |rating| 
        @rating_filter[rating]=true
        curr_ratings.push(rating)
      end
      @movies = Movie.where(:rating => curr_ratings).all
      session[:rating_filter]=@rating_filter
    else
      @movies = Movie.all
    end
    
    if params.has_key?(:sortby)
      order=params[:sortby]
      @movies=@movies.sort_by{|movie| movie[order]}
      instance_variable_set("@#{order}_header_hilite", "hilite") if order!="id"
      session[:sortby]=order
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end
