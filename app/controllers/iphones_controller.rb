class IphonesController < ApplicationController
  before_action :set_iphone, only: %i[ show update destroy ]

  # GET /iphones
  def index
    @iphones = Iphone.all

    render json: @iphones
  end

  # GET /iphones/1
  def show
    render json: @iphone
  end

  # POST /iphones
  def create
    @iphone = Iphone.new(iphone_params)

    if @iphone.save
      render json: @iphone, status: :created, location: @iphone
    else
      render json: @iphone.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /iphones/1
  def update
    if @iphone.update(iphone_params)
      render json: @iphone
    else
      render json: @iphone.errors, status: :unprocessable_content
    end
  end

  # DELETE /iphones/1
  def destroy
    @iphone.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_iphone
      @iphone = Iphone.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def iphone_params
      params.expect(iphone: [ :name, :storage, :price, :color ])
    end
end
