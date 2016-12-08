class GithubUsersController < ApplicationController

  def index

  end

  def list
    if params[:value].present?
      uri = URI.parse("https://api.github.com/search/users")
      @query_params = {}
      @query_params[:q] = params[:value]
      @query_params[:per_page] = 50
      @query_params[:page] = params[:page].present? ? params[:page] : 1
      uri.query = URI.encode_www_form(@query_params)
      query_result = JSON.parse(Net::HTTP.get_response(uri).body)
      if query_result["total_count"].to_i == 0
        redirect_to root_path
      else
        @page = @query_params[:page]
        @total_pages = (query_result["total_count"].to_i % @query_params[:per_page].to_i) == 0 ? (query_result["total_count"].to_i / @query_params[:per_page].to_i).to_i : (query_result["total_count"].to_i / @query_params[:per_page].to_i).to_i + 1
        @github_users = query_result["items"]
      end
    else
      redirect_to root_path
    end
  end

  def show
    @github_user = JSON.parse(Net::HTTP.get_response(URI.parse("https://api.github.com/users/#{params[:id]}")).body)
    @github_user_repos = JSON.parse(Net::HTTP.get_response(URI.parse(@github_user["repos_url"])).body).sort_by{|x| x["updated_at"]}.reverse
  end

  def search
    if github_user_search_params.present? && github_user_search_params[:exact]
      redirect_to github_user_path(id: github_user_search_params[:value])
    elsif github_user_search_params.present? && github_user_search_params[:value].present?
      redirect_to list_github_users_path(github_user_search_params)
    else
      redirect_to root_path
    end
  end

  private

  def github_user_search_params
    params.require(:search).permit(:value, :exact)
  end
end