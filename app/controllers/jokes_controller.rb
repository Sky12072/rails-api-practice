class JokesController < ApplicationController
    before_action :authenticate_user, except: [:index, :random, :show]
    before_action :set_joke, only: [:show, :update, :destroy]
    before_action :check_ownership, only: [:update, :destroy]

    # why before_action doesn't use  ':' symbol ? because it's a method ?
    def index
        @jokes = Joke.all
        render json: @jokes
    end
    # so this 'Joke' variable is coming from the Joke model which is Joke itself
    def create
        # 'current_user' is from knock feature
        @joke = current_user.jokes.create(joke_params)
        if @joke.errors.any?
            render json: @joke.errors, status: :unprocessable_entity
        else 
            render json: @joke, status: 201
        end
    end

    def show
        render json: @joke.transform_joke
    end

    def update
        @joke.update(joke_params)
        if @joke.errors.any?
            render json: @joke.errors, status: :unprocessable_entity
        else 
            render json: @joke, status: 201
        end
    end

    def destroy
        @joke.delete
        render json: 204
    end

    def random
        if params[:category]
            puts "Searching for #{params[:category]}"
            count = Joke.find_by_category(params[:category]).count
            if count == 0
                return render json: {error: "No Jokes of that category"}, status: 404
            end
            @joke = Joke.find_by_category(params[:category]).offset(rand(count)).first
        else 
            # puts "Hello #{params[:name]}"
            offset = rand(Joke.count)
            @joke = Joke.offset(offset).first
        end
        render json: @joke, status: 200
    end

    private
    def joke_params
        params.require(:joke).permit(:category_id, :body)
    end

    def set_joke
        begin
        @joke = Joke.find(params[:id])
        rescue
            render json: {error: "Joke not found"}, status: 404
        end
    end

    def check_ownership
        if current_user.id != @joke.user.id
            render json: {error: "You don't have permission to do that"}, status: 401
        end
    end

end

