# -*- encoding : utf-8 -*-
class Tender::TenderController < ApplicationController
  before_action :validate_tender_login, only: [:show, :download_file] 
  #before_action :validate_tender_admin, only: [:report, :item, :delete_file]

  def show
  	@node = Site::Node.where(nid: params[:nid]).first
    @tenderuser = Tender::Tenderuser.where(user: current_user).first
  end

  def report
  	@search = params[:search] == 'clear' ? {} : params[:search]
    downloads = Tender::Download
    tenderusers = Tender::Tenderuser
    tenders = Tender::Tender

    @result = []

  	if @search 
        tenders = tenders.where(tenderno: @search[:tenderno].mongonize) if @search[:tenderno].present?

        tenderusers = tenderusers.where(organization_name: @search[:organization_name].mongonize) if @search[:organization_name].present?
        tenderusers = tenderusers.where(organization_type: @search[:organization_type].mongonize) if @search[:organization_type].present?
        tenderusers = tenderusers.where(director_name: @search[:director_name].mongonize) if @search[:director_name].present?
        tenderusers = tenderusers.where(rs_tin: @search[:rs_tin]) if @search[:rs_tin].present?
  	end
  	
  	map_down = %Q{
  		function() {
	  			 emit({tenderuser: this.tenderuser_id, nid: this.nid}, {count: 1})
				}
  	}

  	reduce_down = %Q{
  		function(key, values) {
        var result = {organization_name: 'd', count:0}
  			values.forEach(function(value) {
            result.count += value.count;
  			});
			return result;
  		}
  	}

     @down = downloads.map_reduce(map_down,reduce_down).out(inline: true)
     @down.each do |d|
       @tender = tenders.where(nid: d['_id']['nid']).first
       @user = tenderusers.where(_id: d['_id']['tenderuser']).first
       if @user && @tender
        @result << { organization_name: @user.organization_name,
                     organization_type: @user.organization_type,
                     director_name: @user.director_name,
                     tenderno: @tender.tenderno,
                     count: d['value']['count']
                  }
       end
     end

  end

  def index
  	@search = params[:search] == 'clear' ? {} : params[:search]
  	ten = Site::Node.joins("JOIN telasi.field_data_field_content_type ON telasi.field_data_field_content_type.entity_type = 'node' and telasi.field_data_field_content_type.entity_id = nid and telasi.field_data_field_content_type.field_content_type_value = 'tenders'").where(type: 'news', language: I18n.locale).order('created DESC')

    if @search
      ten = ten.where(nid: @search[:nid]) if @search[:nid].present?
      ten = ten.where(title: @search[:title]) if @search[:title].present?
      ten = ten.where(created_dt: @search[:created_dt]) if @search[:created_dt].present?
    end

  	@tenders = ten.paginate(page: params[:page], per_page: 20)
  end

  def list
    @search = params[:search] == 'clear' ? {} : params[:search]
    ten = Site::Node.joins("JOIN telasi.field_data_field_content_type ON telasi.field_data_field_content_type.entity_type = 'node' and telasi.field_data_field_content_type.entity_id = nid and telasi.field_data_field_content_type.field_content_type_value = 'tenders'").where(type: 'news', language: I18n.locale).order('created DESC')

    if @search
      ten = ten.where(nid: @search[:nid]) if @search[:nid].present?
      ten = ten.where(title: @search[:title]) if @search[:title].present?
      ten = ten.where(created_dt: @search[:created_dt]) if @search[:created_dt].present?
    end

    @tenders = ten.paginate(page: params[:page], per_page: 20)
  end

  def item
    node = Site::Node.where(nid: params[:nid]).first
    @title = node.title
  	@tender = Tender::Tender.where(nid: params[:nid]).first || Tender::Tender.new(nid: params[:nid], tenderno: node.tenderno)

    if request.post? and params[:sys_file]
      @file = Sys::File.new(params.require(:sys_file).permit(:file))
      if @tender.save and @file.save
      	 @tender.file << @file
      end
    else
  	 @file = @tender.file.last || Sys::File.new
    end
  end

  def download_file
  	@tenderuser = Tender::Tenderuser.where(user: current_user).first
  	if @tenderuser
  		@download = Tender::Download.new(tenderuser: @tenderuser, nid: params[:nid], datetime: Time.now)
  		@tender = Tender::Tender.where(nid: params[:nid]).first
  		if @tender and @tender.file
	  	    send_file "#{Dir.getwd}/public/#{@tender.file.last.file_url}"
	  	    @download.save
	  	end
    end
  end

  def delete_file
   @tender = Tender::Tender.where(nid: params[:nid]).first
   if @tender 
    if @tender.file
   	 @tender.file.destroy
    end
    @tender.destroy
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
