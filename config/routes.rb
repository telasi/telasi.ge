# -*- encoding : utf-8 -*-
TelasiGe::Application.routes.draw do
  scope controller: 'dashboard' do
    match '/login', action: 'login', as: 'login', via: ['get', 'post']
    get '/logout', action: 'logout', as: 'logout'
    match '/register', action: 'register', as: 'register', via: ['get', 'post']
    get '/register_complete', action: 'register_complete', as: 'register_complete'
    get '/confirm', action: 'confirm', as: 'confirm'
    match '/restore', action: 'restore', as: 'restore', via: ['get', 'post']
    match '/restore_password', action: 'restore_password', as: 'restore_password', via: ['get', 'post']
  end

  scope '/profile', controller: 'profile' do
    get '/', action: 'index', as: 'profile'
    match '/edit', action: 'edit', as: 'edit_profile', via: ['get', 'put']
    match '/change_password', action: 'change_password', as: 'change_password', via: ['get', 'post']
  end

  scope '/customers', controller: 'customers' do
    get '/', action: 'index', as: 'customers'
    get '/search', action: 'search', as: 'search_customer'
    match '/info/:custkey', action: 'info', as: 'customer_info', via: ['get', 'post']
    get '/complete/:custkey', action: 'complete', as: 'add_customer_complete'
    get '/history/:custkey', action: 'history', as: 'customer_history'
    get '/trash_history/:custkey', action: 'trash_history', as: 'customer_trash_history'
  end

  scope '/calculator', controller: 'calculator' do
    get '/', action: 'index', as: 'calculator_url'
  end

  scope '/new_customer', controller: 'new_customer' do
    get '/', action: 'index', as: 'new_customer'
    match '/new', action: 'new', as: 'new_new_customer', via: ['get', 'post']
    get '/show/:id', action: 'show', as: 'show_new_customer'
    match '/edit/:id', action: 'edit', as: 'edit_new_customer', via: ['get', 'put']
    get '/payments/:id', action: 'payments', as: 'new_customer_payments'
    get '/accounts/:id', action: 'accounts', as: 'new_customer_accounts'
    match '/accounts/:id/new', action: 'new_account', as: 'new_customer_new_account', via: ['get', 'post']
    match '/accounts/:id/edit/:item_id', action: 'edit_account', as: 'new_customer_edit_account', via: ['get', 'put']
    delete '/accounts/:id/delete/:item_id', action: 'delete_account', as: 'new_customer_delete_account'
    get '/files/:id', action: 'files', as: 'new_customer_files'
    match '/files/:id/upload', action: 'upload_file', as: 'new_customer_upload_file', via: ['get', 'post']
    delete '/files/:id/delete/:file_id', action: 'delete_file', as: 'new_customer_delete_file'
  end

  scope '/applications', controller: 'applications' do
    get '/', action: 'index', as: 'applications'
  end

  namespace 'admin' do
    scope '/users', controller: 'users' do
      get '/', action: 'index', as: 'users'
      get '/show/:id', action: 'show', as: 'user'
      match '/new', action: 'new', as: 'new_user', via: ['get', 'post']
      match '/edit/:id', action: 'edit', as: 'edit_user', via: ['get', 'post']
      delete '/delete/:id', action: 'delete', as: 'delete_user'
    end
    scope '/customers', controller: 'customers' do
      get '/', action: 'index', as: 'customers'
      get '/show/:id', action: 'show', as: 'show_customer'
      get '/confirm/:id', action: 'confirm', as: 'confirm_customer'
      match '/deny/:id', action: 'deny', as: 'deny_customer', via: ['get', 'post']
      delete '/delete/:id', action: 'delete', as: 'delete_customer'
    end
    get '/network' => redirect('/network')
  end

  namespace 'network' do
    scope '/', controller: 'base' do
      get '/', action: 'index', as: 'home'
    end
    scope '/tariffs', controller: 'tariffs' do
      get '/', action: 'index', as: 'tariffs'
      get '/generate_tariffs', action: 'generate_tariffs', as: 'generate_network_tariffs'
    end
    scope '/aviso', controller: 'aviso' do
      get '/', action: 'index', as: 'avisos'
      get '/show/:id', action: 'show', as: 'aviso'
      post '/link/:id', action: 'link', as: 'link_aviso'
      delete '/delink/:id', action: 'delink', as: 'delink_aviso'
      match '/add_customer/:id', action: 'add_customer', as: 'add_aviso_customer', via: ['get', 'post']
      post '/sync', action: 'sync', as: 'sync_avisos'
    end
    scope '/new_customer', controller: 'new_customer' do
      get '/', action: 'index', as: 'new_customers'
      match '/new', action: 'add_new_customer', as: 'add_new_customer', via: ['get', 'post']
      match '/edit/:id', action: 'edit_new_customer', as: 'edit_new_customer', via: ['get', 'post']
      get   '/:id', action: 'new_customer', as: 'new_customer'
      delete '/delete/:id', action: 'delete_new_customer', as: 'delete_new_customer'
      match '/add_account/:id', action: 'add_new_customer_account', as: 'add_new_customer_account', via: ['get', 'post']
      match '/edit_account/:app_id/:id', action: 'edit_new_customer_account', as: 'edit_new_customer_account', via: ['get', 'post']
      delete '/delete_account/:app_id/:id', action: 'delete_new_customer_account', as: 'delete_new_customer_account'
      match '/change_status/:id', action: 'change_status', as: 'change_new_customer_status', via: ['get', 'post']
      match '/send_sms/:id', action: 'send_new_customer_sms', as: 'send_new_customer_sms', via: ['get', 'post']
      match '/upload_file/:id', action: 'upload_file', as: 'upload_new_customer_file', via: ['get', 'post']
      delete '/delete_file/:id/:file_id', action: 'delete_file', as: 'delete_new_customer_file'
      match '/link_bs_customer/:id', action: 'link_bs_customer', as: 'link_bs_customer', via: ['get','post']
      delete '/remove_bs_customer/:id', action: 'remove_bs_customer', as: 'remove_bs_customer'
      match '/change_plan_date/:id', action: 'change_plan_date', as: 'change_plan_date', via: ['get','post']
      match '/change_real_date/:id', action: 'change_real_date', as: 'change_real_date', via: ['get','post']
      post '/sync_accounts/:id', action: 'sync_accounts', as: 'new_customer_sync_accounts'
      post '/send_to_bs/:id', action: 'send_to_bs', as: 'new_customer_send_to_bs'
      get '/paybill/:id', action: 'paybill', as: 'new_customer_paybill'
      get '/print/:id', action: 'print', as: 'new_customer_print'
      post '/send_factura/:id', action: 'send_factura', as: 'new_customer_send_factura'
      match '/new_control_item/:id', action: 'new_control_item', as: 'new_customer_new_control_item', via: ['get','post']
      match '/edit_control_item/:id', action: 'edit_control_item', as: 'new_customer_edit_control_item', via: ['get','post']
      delete '/delete_control_item/:id', action: 'delete_control_item', as: 'new_customer_delete_control_item'
    end
    scope '/change_power', controller: 'change_power' do
      get '/', action: 'index', as: 'change_power_applications'
      match '/new', action: 'new', as: 'add_change_power', via: ['get', 'post']
      match '/edit/:id', action: 'edit', as: 'edit_change_power', via: ['get', 'post']
      get   '/:id', action: 'show', as: 'change_power'
      delete '/delete/:id', action: 'delete', as: 'delete_change_power'
    end
    scope '/stages', controller: 'stages' do
      get '/', action: 'index', as: 'stages'
      match '/new', action: 'new', as: 'new_stage', via: ['get', 'post']
      match '/edit/:id', action: 'edit', as: 'edit_stage', via: ['get', 'post']
      delete '/delete/:id', action: 'delete', as: 'delete_stage'
    end
  end

  namespace 'select' do
    scope 'customer', controller: 'customer' do
      get '/', action: 'index', as: 'customer'
    end
  end

  root 'dashboard#index'
end
