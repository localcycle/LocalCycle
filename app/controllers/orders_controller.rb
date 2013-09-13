class OrdersController < ApplicationController
load_and_authorize_resource

def show
end

def edit
  @order.build_transaction
  if (@order.address == nil)
    @order.build_address
  end
  render :billing
  
end

def update
  if @order.update_attributes(params[:order])
    transaction = AuthorizeNet::AIM::Transaction.new(ANET_API_LOGIN_ID, ANET_KEY,
      :gateway => ANET_GATEWAY)
    puts transaction.to_yaml
    credit_card = AuthorizeNet::CreditCard.new(@order.transaction.credit_card, @order.transaction.get_exp)
    
    response = transaction.purchase( @order.total, credit_card)
    
    if response.success?
      @order.finalize_transaction(response.authorization_code)
      
      @order.cart_items.collect{|ci| ci.good.creator}.uniq.each do |producer|
     	  ProducerMailer.new_order(current_user, producer, @order).deliver
     	end
     	
     	@order = Order.find(@order.id)
      BuyerMailer.checkout(current_user, @order).deliver
      
      puts "PROVIDER: #{@order.cart_items.to_yaml}"
     

     	
		
      render :success
    else
      flash.now[:error] = "There was an error while processing your payment. #{response.response_reason_text}"
      render :billing
    end
  else
    render :billing
  end
  
    
end



end