class SessionsController < ApplicationController
  require 'httparty'
  def new
  end

  def create
  auth = {
  :username => params["email"], 
  :password => params["password"]
   }

   options = { 
  :basic_auth => auth 
   }
   results = HTTParty.get("http://riag.kalpah.com/api/v1/request_id_generator", options)
  if results["status"] == 1 && results["Id"].present?
    session[:user_id] = results["Id"]
    session[:username] = params["email"]
    session[:password] = params["password"]
    redirect_to users_path
  else
    flash.now.alert = "Email or password is invalid"
    render "new"
  end
end

def destroy
  session[:user_id] = nil
  redirect_to login_path, notice: "Logged out!"
end

end
