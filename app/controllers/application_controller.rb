class ApplicationController < ActionController::API
  before_action :set_variables

  def set_variables
   @page_size = 50
  end
end
