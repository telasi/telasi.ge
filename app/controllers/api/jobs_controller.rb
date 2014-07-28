# -*- encoding : utf-8 -*-
class Api::JobsController < Api::ApiController
  def status
    job = Sys::BackgroundJob.find(params[:id])
    render json: { completed: job.completed? }
  end

  def download
    job = Sys::BackgroundJob.find(params[:id])
    send_file job.path
  end
end