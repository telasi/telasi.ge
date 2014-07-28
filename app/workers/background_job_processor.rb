# -*- encoding : utf-8 -*-
class BackgroundJobProcessor
  include Sidekiq::Worker
  include Sys::BackgroundJobConstants

  def perform(id)
    job = Sys::BackgroundJob.find(id)
    unless job.completed?
      begin
        process_job(job)
        job.success = true
      rescue Exception => ex
        job.failed = true
        job.trace = ex.backtrace.join("\n")
      end
      job.save
    end
  end

  private

  def process_job(job)
    # TODO
  end
end