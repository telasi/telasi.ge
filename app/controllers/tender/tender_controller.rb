# -*- encoding : utf-8 -*-
class Tender::TenderController < ApplicationController

  require 'will_paginate/array'

  before_action :validate_tender_login, only: [:show, :download_file] 
  #before_action :validate_tender_admin, only: [:report, :item, :delete_file]

  def show
  	@node = Site::Node.where(tnid: params[:nid], language: I18n.locale).first
    @tenderuser = Tender::Tenderuser.where(user: current_user).first
    @tender = Tender::Tender.where(nid: @node.tnid).first if @node
  end

  def report
  	@search = params[:search] == 'clear' ? {} : params[:search]
    downloads = Tender::Download
    tenderusers = Tender::Tenderuser
    tenders = Tender::Tender

    @result = []

  	# if @search 
   #      tenders = tenders.where(tenderno: @search[:tenderno].mongonize) if @search[:tenderno].present?

   #      tenderusers = tenderusers.where(organization_name: @search[:organization_name].mongonize) if @search[:organization_name].present?
   #      tenderusers = tenderusers.where(organization_type: @search[:organization_type].mongonize) if @search[:organization_type].present?
   #      tenderusers = tenderusers.where(director_name: @search[:director_name].mongonize) if @search[:director_name].present?
   #      tenderusers = tenderusers.where(rs_tin: @search[:rs_tin]) if @search[:rs_tin].present?
  	# end
  	
  	# map_down = %Q{
  	# 	function() {
	  # 			 emit({tenderuser: this.tenderuser_id, nid: this.nid}, {count: 1})
			# 	}
  	# }

  	# reduce_down = %Q{
  	# 	function(key, values) {
   #      var result = {organization_name: 'd', count:0}
  	# 		values.forEach(function(value) {
   #          result.count += value.count;
  	# 		});
			# return result;
  	# 	}
  	# }

    match_patern = {}
    if @search 
        match_patern = { "nid" => { "$in" => tenders.where(tenderno: @search[:tenderno].mongonize).map{ |x| x.nid }}} if @search[:tenderno].present?

        tenderusers = tenderusers.where(organization_name: @search[:organization_name].mongonize) if @search[:organization_name].present?
        tenderusers = tenderusers.where(organization_type: @search[:organization_type].mongonize) if @search[:organization_type].present?
        tenderusers = tenderusers.where(director_name: @search[:director_name].mongonize) if @search[:director_name].present?
        tenderusers = tenderusers.where(rs_tin: @search[:rs_tin]) if @search[:rs_tin].present?

        if tenderusers.count > 0 and ( @search[:organization_name].present? or @search[:organization_type].present? or @search[:director_name].present? or @search[:rs_tin].present?)
          match_patern.merge!({ "tenderuser_id" => { "$in" => tenderusers.map{ |x| x._id }}})
        end
    end

     #@down = downloads.map_reduce(map_down,reduce_down).out(inline: true)
     @down = Tender::Download.collection.aggregate([
                                                    { "$match" => match_patern },
                                                    {"$group" => { 
                                                        "_id" => { 
                                                          "tenderuser" => "$tenderuser_id", 
                                                          "nid" => "$nid" 
                                                        }, 
                                                        "count" => { 
                                                          "$sum" => 1 
                                                         } 
                                                        } 
                                                    }])

    # @down.each do |d|
    #   @tender = tenders.where(nid: d['_id']['nid']).first
    #   @user = tenderusers.where(_id: d['_id']['tenderuser']).first
    #   if @user && @tender
    #    @result << { organization_name: @user.organization_name,
    #                  organization_type: @user.organization_type,
    #                  director_name: @user.director_name,
    #                  tenderno: @tender.tenderno,
    #                  #count: d['value']['count'],
    #                  count: d['count'],
    #                  nid: @tender.nid,
    #               }
    #    end
    #  end

     @result = @down.paginate(page: params[:page], per_page: 20)

  end

  def index
  	@search = params[:search] == 'clear' ? {} : params[:search]
  	ten = Site::Node.joins("JOIN telasi.field_data_field_content_type ON telasi.field_data_field_content_type.entity_type = 'node' and telasi.field_data_field_content_type.entity_id = nid and telasi.field_data_field_content_type.field_content_type_value = 'tenders'").where(type: 'news', language: I18n.locale).order('created DESC')

    if @search
      ten = ten.where(nid: @search[:nid]) if @search[:nid].present?
      ten = ten.where(title: @search[:title].mongonize) if @search[:title].present?
      ten = ten.where("created >= ?", (DateTime.strptime(@search[:created_dt],'%Y-%m-%d') - 4.hours).to_i) if @search[:created_dt].present?
      ten = ten.where("created <= ?", (DateTime.strptime(@search[:created_dt],'%Y-%m-%d') - 4.hours + 1.day).to_i) if @search[:created_dt].present?
    end

  	@tenders = ten.paginate(page: params[:page], per_page: 20)
  end

  def list
    @search = params[:search] == 'clear' ? {} : params[:search]
    ten = Site::Node.joins("JOIN telasi.field_data_field_content_type ON telasi.field_data_field_content_type.entity_type = 'node' and telasi.field_data_field_content_type.entity_id = nid and telasi.field_data_field_content_type.field_content_type_value = 'tenders'").where(type: 'news', language: I18n.locale).order('created DESC')

    if @search
      ten = ten.where(nid: @search[:nid]) if @search[:nid].present?
      ten = ten.where(title: @search[:title].mongonize) if @search[:title].present?
      ten = ten.where(created: @search[:created_dt]) if @search[:created_dt].present?
    end

    @tenders = ten.paginate(page: params[:page], per_page: 20)
  end

  def item
    node = Site::Node.where(nid: params[:nid]).first
    @title = node.title
  	@tender = Tender::Tender.where(nid: node.tnid).first || Tender::Tender.new(nid: node.tnid, tenderno: node.tenderno)

    if request.post? and params[:sys_file]
      @file = Sys::File.new(params.require(:sys_file).permit(:file))
      if @tender.save and @file.save
      	 @tender.files << @file
      end
    else
  	 @file = @tender.files.last || Sys::File.new
    end
  end

  def download_file
  	@tenderuser = Tender::Tenderuser.where(user: current_user).first
  	if @tenderuser
      @node = Site::Node.where(nid: params[:nid]).first
  		@download = Tender::Download.new(tenderuser: @tenderuser, nid: @node.tnid, datetime: Time.now)
  		@tender = Tender::Tender.where(nid: @node.tnid).first if @node
  		if @tender and @tender.files
          if params[:file_id]
            @id = BSON::ObjectId.from_string(params[:file_id])
            @f = @tender.files.where( _id: @id ).first
            if @f
             send_file "#{Dir.getwd}/public/#{@f.file_url}"
            end
          else
	  	     send_file "#{Dir.getwd}/public/#{@tender.files.last.file_url}"
          end
	  	    @download.save
	  	end
    end
  end

  def delete_file
   @node = Site::Node.where(nid: params[:nid]).first
   @tender = Tender::Tender.where(nid: @node.tnid).first if @node
   if @tender 
    if @tender.files
   	 @tender.files.destroy
    end
    #@tender.destroy
   end
   redirect_to tender_tender_item_url(nid: params[:nid]) 
  end

  private

  def validate_tender_login
  	unless Tender::Tenderuser.where(user: current_user).first
  	 redirect_to tender_register_url, alert: I18n.t('models.sys_user.errors.login_required')
  	end
  end

  def validate_tender_admin
  	 current_user.admin? if current_user
  end
end
