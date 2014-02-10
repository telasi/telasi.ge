# -*- encoding : utf-8 -*-
class Network::StagesController < ApplicationController
  def index
    @title = I18n.t('models.network.stages.stages')
    @stages = Network::Stage.asc(:numb)
  end

  def new
    @title = I18n.t('models.network.stages.new_stage')
    if request.post?
      @stage = Network::Stage.new(params.require(:network_stage).permit(:name))
      if @stage.save
        Network::Stage.auto_numerate
        redirect_to network_stages_url, notice: I18n.t('models.network.stages.added')
      end
    else
      @stage = Network::Stage.new
    end
  end

  def edit
    @title = I18n.t('models.network.stages.change')
    @stage = Network::Stage.find(params[:id])
    if request.post?
      if @stage.update_attributes(params.require(:network_stage).permit(:name, :numb))
        Network::Stage.auto_numerate
        redirect_to network_stages_url, notice: I18n.t('models.network.stages.changed')
      end
    end
  end

  def delete
    stage = Network::Stage.find(params[:id])
    stage.destroy
    Network::Stage.auto_numerate
    redirect_to network_stages_url, notice: I18n.t('models.network.stages.deleted')
  end

  def nav
    @nav = { 'ქსელი' => network_home_url, 'ეტაპები' => network_stages_url }
    @nav[@title] = nil if @stage
  end
end
