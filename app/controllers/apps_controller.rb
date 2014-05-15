class AppsController < ApplicationController
  before_action :set_app, only: [:show, :edit, :update, :destroy]

  # GET /apps
  def index
    @apps = App.order(:name)
  end

  # GET /apps/1
  def show
  end

  # GET /apps/new
  def new
    @app = App.new
  end

  # GET /apps/1/edit
  def edit
  end

  # POST /apps
  def create
    @app = App.new(app_params)

    if @app.save
      redirect_to @app, notice: 'App was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /apps/1
  def update
    if @app.update(app_params)
      redirect_to @app, notice: 'App was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /apps/1
  def destroy
    @app.destroy
    redirect_to apps_url, notice: 'App was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app
      @app = App.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def app_params
      params.require(:app).permit(:name, :url, :server, :aasm_state, :repository_url, :project_url, :description)
    end
end
