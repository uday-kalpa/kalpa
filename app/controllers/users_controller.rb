class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :index]

  # GET /users
  # GET /users.json
  def index
    @user_form = User.new
    if @user.blank?
      redirect_to login_path
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def user_pdf_generate
      eye_type = user_params["eye_type"] == "0" ? "L" : "R"
      @user = User.create(user_id: params["patient_id"]) do |user|
        user.user_id = user_params["user_id"]
        user.avatar = user_params["avatar"]
        user.name = user_params["name"]
        user.eye_type = eye_type
        user.age = user_params["age"]
        user.sex = user_params["sex"]
        user.IOP = user_params["IOP"]
        user.medical_history = user_params["medical_history"]
      end
      
    if session[:user_id].include? "done"
      begin
        auth = {
          :username => session[:username],
          :password => session[:password]
        }

        options = { 
          :basic_auth => auth 
        }
        results = HTTParty.get("http://riag.kalpah.com/api/v1/request_id_generator", options)
        @request_id = results["Id"]
      rescue => e
        @error = e.message
        Rails.logger.info "Error making call to Payoneer: #{e.message}"
      end
    end

    begin
      upload_response =  HTTParty.post('http://riag.kalpah.com/api/v1/image_uploader', 
                  basic_auth: { username: session[:username], password: session[:password] },
                  body: {:eye => eye_type, :Id => (@request_id || session[:user_id]), :image => File.open(@user.avatar.current_path)},
                  headers: {"Content-Type" => "application/json"} 
                  ) 
      upload_response = JSON.parse(upload_response)
      #Mark the pervious requesrt id as done
      session[:user_id] = session[:user_id].concat("_done")
    rescue => e
      @error = e.message
      Rails.logger.info "Error making call to Payoneer: #{e.message}"
    end    

    if upload_response.present? && upload_response["status"] == 1
      begin
        algo_response = HTTParty.post('http://riag.kalpah.com/api/v1/riag_algo', 
                          basic_auth: { username: session[:username], password: session[:password] },
                          body: {"requestId": upload_response["requestId"], "patientId": user_params["user_id"], "autoCoords": 1, "isDLInfoProvided": 0, "manualCoorectionBoolCup": 0, "manualCoorectionBoolDisc": 0}.to_json,
                          headers: {"Content-Type" => "application/json"}
                          ) 
      rescue => e
        @error = e.message
        Rails.logger.info "Error making call to Payoneer: #{e.message}"
      end
    end
    @algo_response = JSON.parse(File.read('/home/uday/Documents/kprogram/response.json')) rescue nil
    
    if @algo_response["status"] == 1
      begin
        @image_response = HTTParty.post('http://riag.kalpah.com/api/v1/get_resultant_image', 
                  basic_auth: { username: session[:username], password: session[:password] },
                  body: {"requestId": upload_response["requestId"]}.to_json,
                  headers: {"Content-Type" => "application/json"}
                  ) 
      rescue Exception => e
        rror = e.message
        Rails.logger.info "Error making call to Payoneer: #{e.message}"
      end
    end

    if (upload_response.present? && upload_response["status"] == 1) && @algo_response["status"] == 1
      File.open("#{@user.user_id}_#{@user.name}.jpg",'wb') do |f|
        f.write @image_response.body
      end
      uh = UsersHistory.create(user_id: user_params["user_id"], algo: @algo_response)
      image_path = File.expand_path("#{@user.user_id}_#{@user.name}.jpg")
      uh.avatar = File.open(image_path)
      uh.save!
      @user_history = uh
    else
      @error_message ||= "ERROR IN FETCHING THE REPORT"
    end    
    html = render_to_string('user_report_pdf', :layout=>false) # html file
    kit = PDFKit.new(html, :orientation => 'Landscape')
    kit.stylesheets << "/home/uday/ruby-project/kalpa/app/assets/stylesheets/bootstrap.css"
    send_data(kit.to_pdf, :filename => "#patient_#{@user.user_id}_report.pdf", :type => 'application/pdf', :disposition => 'inline')
    

    # html = render_to_string('user_report_pdf', :layout=>false) # html files
    # pdf = WickedPdf.new.pdf_from_string(html)
    # pdf = render_to_string pdf: "app/views/users/user_report_pdf".
    # pdf = WickedPdf.new.pdf_from_string(
    # render_to_string('user_report_pdf', layout: 'layout_pdf.html')
    # )
    #send_data(pdf, :filename => "#patient_#{@user.user_id}_report.pdf", :type => 'application/pdf', :disposition => 'inline')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = session[:user_id]
      if @user.blank?
        session.clear
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:user_id, :avatar, :extras, :name, :eye_type, :medical_history, :sex, :age, :IOP )
    end
end