class CustomersController < ApplicationController
  def index
    @customers = Customer.all
    
    if params[:email].present?
      @customers = @customers.by_email(params[:email])
    end
    
    if params[:phone].present?
      @customers = @customers.by_phone(params[:phone])
    end
    
    @customers = @customers.order(:created_at).page(params[:page])
  end
end
