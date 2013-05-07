class AgreementsController < ApplicationController
  load_and_authorize_resource

  helper_method :sort_column, :sort_direction
  
  require 'csv'

  def index

    @agreements = @agreements.available_supply_or_mine(current_user.id) if current_user.buyer?
    @agreements = @agreements.available_demand_or_mine(current_user.id) if current_user.producer?
    @agreements = filter_and_sort(@agreements, params)

    @agreements = @agreements.paginate(page: params[:page], per_page: (params[:per_page] || DEFAULT_PER_PAGE))

    @product_agreements = @agreements.group_by(&:product)


    @products = filter_and_sort_products(Product.scoped.includes(:agreements), params) if params["show_agreements"].blank?
    @products = @products.paginate(page: params[:page], per_page: (params[:per_page] || DEFAULT_PER_PAGE)) if params["show_agreements"].blank?

    respond_to do |format|
      format.html 
      format.json { render json: @agreements }
    end
  end

  def marketplace
    @agreements = @agreements.standing_supply if current_user.buyer?
    @agreements = @agreements.standing_demand if current_user.producer?
    @agreements = filter_and_sort(@agreements, params)
    @agreements = @agreements.paginate(page: params[:page], per_page: (params[:per_page] || DEFAULT_PER_PAGE))

    @product_agreements = @agreements.group_by(&:product)

    respond_to do |format|
      format.html
      format.json { render json: @agreements }
    end
  end


  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @agreement }
    end
  end

  def modal
    @counter_agreement = @agreement.counter_agreements.build

    respond_to do |format|
      format.js
    end
  end

  def new
    @agreement.agreement_type = params[:agreement_type] unless params[:agreement_type].nil?
    @image = @agreement.images.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @agreement }
    end
  end

  def edit
  end

  def create
    @agreement.images.build(image: @agreement.product.best_pic) unless params[:agreement][:images_attributes]
    @agreement.buyer_id = current_user.id if current_user.buyer?
    @agreement.producer_id = current_user.id if current_user.producer?

    respond_to do |format|
      if @agreement.save
        format.html { redirect_to products_path, notice: 'Agreement was successfully created.' }
        format.json { render json: @agreement, status: :created, location: @agreement }
      else
        format.html { render action: "new" }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @agreement.update_attributes(params[:agreement])
        format.html { redirect_to agreements_path, notice: 'Agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  def accept
    @agreement.producer_id = params["producer_id"] unless params["producer_id"].blank?
    @agreement.buyer_id = params["buyer_id"] unless params["buyer_id"].blank?

    respond_to do |format|
      if @agreement.save
        format.html { redirect_to agreements_path, notice: 'Agreement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @agreement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @agreement.destroy

    respond_to do |format|
      format.html { redirect_to agreements_url }
      format.json { head :no_content }
    end
  end

  private

  def filter_and_sort_products(products, params)
    products = products.by_category_name(params[:category]) unless params[:category].blank?
    products = products.in_category(params[:cat_id]) unless params[:cat_id].blank?

    products = products.by_name(params[:name]) unless params[:name].blank?

    return products.order(sort_product_column + " " + sort_direction)
  end

  def filter_and_sort(agreements, params)

    agreements = agreements.by_complete if !params[:status].blank? and params[:status] == "complete"
    agreements = agreements.by_not_complete if !params[:status].blank? and params[:status] == "proposed"

    agreements = agreements.by_name(params[:name]) unless params[:name].blank?
    agreements = agreements.in_category(params[:cat_id]) unless params[:cat_id].blank?
    agreements = agreements.by_buyer(params[:buyer_id]) unless params[:buyer_id].blank?
    agreements = agreements.by_producer(params[:producer_id]) unless params[:producer_id].blank?

    return agreements.order(sort_column + " " + sort_direction)
  end
  
  def sort_product_column
    sort = params[:sort] || ''
    Agreement.column_names.include?(sort) ? sort : "products.name"
  end

  def sort_column
    sort = params[:sort] || ''
    Agreement.column_names.include?(sort) ? sort : "agreements.name"
  end

  def sort_direction
    direction = params[:direction] || ''
    "ASC DESC".include?(direction) ? direction : "ASC"
  end

end
