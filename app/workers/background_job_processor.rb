# -*- encoding : utf-8 -*-
class BackgroundJobProcessor
  include Sidekiq::Worker
  include Sys::BackgroundJobConstants

  def perform(id)
    # job = Sys::BackgroundJob.find(id)
    # unless job.completed?
    #   case job.name
    #   end
    # end
  end
end