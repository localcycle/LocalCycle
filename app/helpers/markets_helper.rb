module MarketsHelper
  def parsed_params
    new_params = {}
    new_params[:name]=params[:name] unless params[:name].blank?
    new_params[:market_managers]=params[:market_managers] unless params[:market_managers].blank?
    new_params[:state]=params[:state] unless params[:state].blank?

    new_params[:per_page]=params[:per_page] unless params[:per_page].blank?
    new_params
  end

  def full_params
    new_params = {}
    new_params[:name]=params[:name] unless params[:name].blank?
    new_params[:market_managers]=params[:market_managers] unless params[:market_managers].blank?
    new_params[:state]=params[:state] unless params[:state].blank?

    new_params[:sort]=params[:sort] unless params[:sort].blank?
    new_params[:direction]=params[:direction] unless params[:direction].blank?

    new_params[:per_page]=params[:per_page] unless params[:per_page].blank?
    new_params
  end
end
