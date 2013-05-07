class ProductsController < ApplicationController
  load_and_authorize_resource

  helper_method :sort_column, :sort_direction
  
  require 'csv'

  def index

    # Ensure profile
    redirect_to new_buyer_profile_path and return if current_user.buyer? and !current_user.buyer_profile
    redirect_to new_producer_profile_path and return if current_user.producer? and !current_user.producer_profile

    @products = filter_and_sort(@products, params)
    @products = @products.paginate(page: params[:page], per_page: (params[:per_page] || DEFAULT_PER_PAGE))

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end


  def pic

    respond_to do |format|
      format.js {}
    end
  end


  def new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  def edit
  end


  def create

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end


  def update

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end


  def export 
    products = filter_and_sort(@products, params)

    filename = "products_#{Date.today.strftime('%b-%d-%y')}"
    csv_data = CSV.generate do |csv|
      csv << Product.csv_header
      products.each do |t|
        csv << t.to_csv
      end
    end
    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{filename}.csv"
  end

  private

  def filter_and_sort(products, params)
    products = products.available_demand_and_mine_only(current_user.id) unless params[:only_available].blank? or current_user.producer?
    products = products.available_supply_and_mine_only(current_user.id) unless params[:only_available].blank? or current_user.buyer?
    products = products.by_name(params[:name]) unless params[:name].blank?

    products = products.by_buyer(params[:buyer]) unless params[:buyer].blank?
    products = products.by_producer(params[:producer]) unless params[:producer].blank?

    products = products.by_category_name(params[:category]) unless params[:category].blank?
    products = products.in_category(params[:cat_id]) unless params[:cat_id].blank?

    return products.order(sort_column + " " + sort_direction)
  end
  
  def sort_column
    sort = params[:sort] || ''
    Product.column_names.include?(sort) ? sort : "products.name"
  end

  def sort_direction
    direction = params[:direction] || ''
    "ASC DESC".include?(direction) ? direction : "ASC"
  end
end
