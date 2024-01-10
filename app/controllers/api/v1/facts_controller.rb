class Api::V1::FactsController < ApplicationController
    include AuthenticationCheck
  
    before_action :is_user_logged_in
    before_action :set_fact, only: %i[show update destroy]
    before_action :check_access
  
    # GET /members/:member_id/facts
    def index
      @member = Member.find(params[:member_id])
      render json: @member.facts # note that because the facts route is nested inside members
      # we return only the facts belonging to that member
    end
  
    def show
      @member = Member.find(params[:member_id])
      if @fact
        render json: @fact, status: 200
      else
        render json: { error: "Fact not found" }, status: 404
      end
    end
  
    # POST /members/:member_id/facts
    def create
      @member = Member.find(params[:member_id])
      @fact = @member.facts.new(fact_params)
      if @fact.save
        render json: @fact, status: 201
      else
        render json: {
            error:"The fact entry could not be created. #{@fact.errors.full_messages.to_sentence}"
        }, status: 400
      end
    end
  
    # PUT /members/:member_id/facts/:id
    def update
      @member = Member.find(params[:member_id])
      unless @fact
        render json: { error: "Fact not found" }, status: 404
        return
      end
      if @fact.update(fact_params)
        render json: @fact, status: 200
      else
        render json: {
            error:"Unable to update fact: #{@fact.errors.full_messages.to_sentence}"
        }, status: 400
      end
    end
  
    # DELETE /members/:member_id/facts/:id
    def destroy
      if @fact.destroy
        render json: { message: "Fact record successfully deleted." }, status: 200
      else
        render json: { error: "Unable to delete fact" }, status: 400
      end
    end
  
    private
  
    def fact_params
      params.require(:fact).permit(:fact_text, :likes)
    end
  
    def set_fact
      @fact = Fact.find_by(id: params[:id], member_id: params[:member_id])
    end
  
    def check_access
      @member = Member.find(params[:member_id])
      if @member.user_id != current_user.id
        render json: {
            message: "The current user is not authorized for that data."
        }, status: :unauthorized
      end
    end
  end