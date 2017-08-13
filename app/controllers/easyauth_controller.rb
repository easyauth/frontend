class EasyauthController < ApplicationController
  before_action :require_auth, only %i[profile create_cert]
  before_action :require_admin, only %i[admin]

  def profile
    # Show a user's profile
  end

  def admin
    # Provide a listing of all users
    # Allow options like delete, view profile
    # Maybe allow lookup by ID?
  end

  def login
    # Show a login page
  end

  def do_login
    # Actually log in
    # make sure to get the user's info to verify: https://stackoverflow.com/questions/15804425/curl-on-ruby-on-rails
  end

  def register
    # Create a new user
  end

  def create_cert
    # Show a form to create a new certificate
  end

  def index
    # Home page
  end

  private

  def require_auth
    # make sure the user is authenticated, otherwise redirect to login?
  end

  def require_admin
    # make sure the user is an admin, otherwise 403 their ass
  end
end