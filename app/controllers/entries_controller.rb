class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy]
  before_action :load_not_verified_entry, only: [:verification_code_input, :verification, :verification_call, :call_on_phone]

  def index
    @entries = Entry.all
  end

  def show
  end

  def new
    @entry = Entry.new
  end

  def edit
  end

  def create
    @entry = Entry.new(entry_params)
    respond_to do |format|
      if @entry.save
        format.html { redirect_to entry_verification_code_input_path(@entry) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to @entry, notice: I18n.t('notice.update', name: @entry.class.model_name.human) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to entries_url }
    end
  end

  def verification_code_input
  end

  def verification
    if @entry.verify_and_save(params[:entry])
      redirect_to @entry, notice: I18n.t('notice.create', name: @entry.class.model_name.human)
    else
      render :verification_code_input
    end
  end

  def verification_call
    response = Twilio::TwiML::Response.new do |r|
      r.Say "こんにちは！ご登録ありがとうございます。あなたの認証コードは、#{@entry.verification_code}です。",
        voice: 'woman'
    end

    render xml: response.text
  end

  def call_on_phone
    @entry.send_verification_code
  end

  private
  def set_entry
    @entry = Entry.find(params[:id])
  end

  def entry_params
    params.require(:entry).permit(:name, :email, :mobile_number, :verification_code,  :verified)
  end

  def load_not_verified_entry
    @entry = Entry.not_verified.id_is(params[:entry_id]).last
  end
end
