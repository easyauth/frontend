class EasyauthController < ApplicationController
  before_action :require_auth, only: %i[profile create_cert]
  before_action :require_admin, only: %i[admin]

  def profile
    # Show a user's profile
    response = call_backend("http://easyauth.org/api/users/#{params[:id]}", "GET", {
      apikey: session[:apikey],
      })
    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render status: 500
      return
    end

    @user = parsed_response[:user]
  end

def do_profile
    response = call_backend("http://easyauth.org/api/users/#{params[:id]}", "PATCH", {
      apikey: session[:apikey],
      name: params[:name],
      email: params[:email],
      password: params[:password]
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :profile, id: params[:id], status: 500
      return
    end

    if response.code == "200" || response.code == "202"
      cache_user_info_2(parsed_response[:user]) if parsed_response[:user][:id] == session[:id]
    else
      flash[:error] = parsed_response[:error]
      render :profile, id: params[:id], status: 401
      return
    end
end


def delete_user
  end



def do_delete_user
response = call_backend("http://easyauth.org/api/users/#{params[:id]}", "DELETE", { 
      apikey: session[:apikey],
      id: params[:id]
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :delete_user, id: params[:id], status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :delete_user, id: params[:id], status: 401
      return
    end

    flash[:notice] = 'Please check your email to confirm account deletion.'
  end

def delete_certificate
end

def do_delete_certificate
response = call_backend("http://easyauth.org/api/certificates/#{params[:id]}", "DELETE", { 
      apikey: session[:apikey]
 
      })

    if response.code == "204"
      flash[:notice] = "Certificate deleted."
      redirect_to '/'
      return 
    end

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :delete_certificate, id: params[:id], status: 401
      return
    end

    flash[:error] = parsed_response[:error]
    render :delete_certificate, id: params[:id], status: 401
end

def revoke_certificate
end



def do_revoke_certificate
response = call_backend("http://easyauth.org/api/certificates/#{params[:id]}", "PATCH", { 
      apikey: session[:apikey],
      id: params[:id],
      valid: false
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :revoke_certificate, id: params[:id], status: 401
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :revoke_certificate, id: params[:id], status: 401
      return
    end    
    flash[:notice] = 'Certificate revoked.'
    redirect_to '/'

end




  def admin
    # Provide a listing of all users
    # Allow options like delete, view profile
    # Maybe allow lookup by ID?

response = call_backend("http://easyauth.org/api/users", "GET", { 
      apikey: session[:apikey]     
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :error, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :error, status: response.code.to_i
      return
    end

    @users = parsed_response[:users].sort_by do |user|
      user[:id]
    end
  end
  


  def do_admin
  end

  def login
    # Show a login page
    if session[:authenticated]
      flash[:error] = "Already logged in"
      render :error, status: 403
    end
 end

 def do_login
    # Actually log in
    # make sure to get the user's info to verify: https://stackoverflow.com/questions/15804425/curl-on-ruby-on-rails
    
    response = call_backend("http://easyauth.org/api/login", "POST", { 
      email: params[:email],
      password: params[:password]
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :login, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :login, status: 401
      return
    end

    session[:id] = parsed_response[:authenticated_as_id]
    session[:apikey] = parsed_response[:apikey]
    session[:authenticated] = true

    cache_user_info(parsed_response[:user])

    flash[:notice] = 'Logged in!'
    redirect_to '/'
  end



  def api_login
    # Show a login page
    if session[:authenticated]
      flash[:error] = "Already logged in"
      render :error, status: 403
    end
 end

 def do_api_login
    # Actually log in
    # make sure to get the user's info to verify: https://stackoverflow.com/questions/15804425/curl-on-ruby-on-rails
    
    response = call_backend("http://easyauth.org/api/api_login", "POST", { 
      email: params[:email],
      password: params[:password]
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :api_login, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :api_login, status: 401
      return
    end

    session[:id] = parsed_response[:authenticated_as_id]
    session[:apikey] = parsed_response[:apikey]
    session[:authenticated] = true

    cache_api_user_info(parsed_response[:user])

    flash[:notice] = 'Logged in!'
    redirect_to '/'
  end





  def logout
    reset_session if session[:authenticated]
    flash[:notice] = 'Logged out.'
    redirect_to '/'
  end

  def register
  end  

  def do_register
    # Create a new user

    response = call_backend("http://easyauth.org/api/users", "POST", { 
      name:  params[:name],
      email: params[:email],
      password: params[:password]
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :register, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :register, status: 401
      return
    end
    flash[:notice] = "Account created! Follow the instructions in your email to activate it."
    redirect_to '/'
  end

  def view_api_key_user
    response = call_backend("http://easyauth.org/api/api_key_users/#{params[:id]}", "GET", { 
      apikey: session[:apikey]
    })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :error, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :error, status: 401
      return
    end  

    @user = parsed_response[:user]
  end

  def apikey
  end  

  def do_apikey
    response = call_backend("http://easyauth.org/api/api_key_users/", "POST", { 
      email: params[:email],
      password: params[:password]
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :apikey, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :apikey, status: 401
      return
    end
    flash[:notice] = "Account created! Follow the instructions in your email to activate it."
    redirect_to '/'
  end




  def validate

  end


  def do_validate
    response = call_backend("http://easyauth.org/api/users/#{session[:id]}", "PATCH", {
      validation_code: params[:validation_code]
      })

    if response.code == "204"
      flash[:notice] = "Account deleted."
      redirect_to '/'
      return 
    end

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :validate, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :validate, status: 401
      return
    end
    flash[:notice] = "Email address validated!"
    redirect_to '/'
  end


  def validate_api
    render :validate
  end


  def do_validate_api
    puts "ID: #{session[:id]}"

    response = call_backend("http://easyauth.org/api/api_key_users/#{session[:id]}", "PATCH", {
      validation_code: params[:validation_code]
      })

    if response.code == "204"
      flash[:notice] = "Account deleted."
      redirect_to '/'
      return 
    end

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :validate, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :validate, status: 401
      return
    end
    flash[:notice] = "Email address validated!"
    redirect_to '/'
  end



  def create_cert
    # Show a form to create a new certificate

  end

  def do_create_cert
    response = call_backend("http://easyauth.org/api/certificates", "POST", {
      csr: params[:pem_certificate],
      apikey: session[:apikey]
      })

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue
      flash[:error] = "Unspecified error"
      render :create_cert, status: 500
      return
    end

    unless response.code.start_with? "2"
      flash[:error] = parsed_response[:error]
      render :create_cert, status: 401
      return
    end
    uri = URI(parsed_response[:certificate][:download])
    params = {apikey: session[:apikey]}
    uri.query = params.to_query
    redirect_to uri.to_s
  end
  


def index
    # Home page
  end

  private

  def require_auth
    redirect_to '/' and return unless session[:authenticated]
    response = call_backend("http://easyauth.org/api/login", "GET", {
      apikey: session[:apikey]
      })
    unless response.code.start_with? "2"
      reset_session
      flash[:error] = "Session expired!"
      redirect_to '/'
    end
  end

  def require_admin
    # make sure the user is an admin, otherwise 403 their ass
  end

  def cache_user_info(url)
    response = call_backend(url, "GET", {apikey: session[:apikey]})

    parsed_response = JSON.parse(response.body, symbolize_names: true)

    if response.code == "200"
      session[:name] = parsed_response[:user][:name]
      session[:email] = parsed_response[:user][:email]
      session[:admin] = parsed_response[:user][:admin]
    end
  end

 def cache_api_user_info(url)
    response = call_backend(url, "GET", {apikey: session[:apikey]})

    begin
      parsed_response = JSON.parse(response.body, symbolize_names: true)
    rescue; end

    if response.code == "200"
      session[:email] = parsed_response[:user][:email]
    end
  end

  def cache_user_info_2(user)
    session[:name] = user[:name]
    session[:email] = user[:email]
  end
end