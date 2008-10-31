require File.dirname(__FILE__) + '/spec_helper'


describe 'destroy_resource with plural resource' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_path).and_return('/tables/1')
    @table = mock('table', :to_param => 1)
  end
  
  it "should create a form with resourceful classes" do
    markup = @view.destroy_table(@table)
    markup.should have_tag('form.destroy.table.destroy_table')
  end
  
  it "should render authenticity token" do
    @view.should_receive(:token_tag)
    @view.destroy_table(@table)
  end

  it "should allow giving the form an id via the :id option" do
    markup = @view.destroy_table(@table, :id => 'logout_form')
    markup.should have_tag('form#logout_form')
  end
  
  it "should allow adding custom classes" do
    markup = @view.destroy_table(@table, :class => 'dining')
    markup.should have_tag('form.destroy.table.dining.destroy_table.dining_table')
  end
  
  it "should submit to the resource_path" do
    @view.should_receive(:table_path).with(@table).and_return('/tables/1')
    markup = @view.destroy_table(@table)
    markup.should have_tag('form[action=/tables/1]')
  end
  
  it "should send the method 'delete' as a hidding field" do
    markup = @view.destroy_table(@table)
    markup.should have_tag('form input[type=hidden][name=_method][value=delete]')
  end
  
  it "should have a submit button labeled 'Delete' by default" do
    markup = @view.destroy_table(@table)
    markup.should have_tag('form button[type=submit]', 'Delete')
  end
  
  it "should allow passing in a custom label to be used for the button" do
    markup = @view.destroy_table(@table, :label => 'Remove')
    markup.should have_tag('form button[type=submit]', 'Remove')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.destroy_table(@table, :button => {:title => 'Click to remove table'})
    markup.should have_tag('form.destroy_table') do
      with_tag('button[type=submit][title=Click to remove table]')
    end
  end
  
  it "should allow sending additional parameters via :sending" do
    markup = @view.destroy_table(@table, :sending => {:return_to => 'url'})
    markup.should have_tag('form.destroy_table') do
      with_tag('input[type=hidden][name=return_to][value=url]')
    end
  end
  
  it "should allow sending additional parameters via :parameters (legacy)" do
    markup = @view.destroy_table(@table, :parameters => {:return_to => 'url'})
    markup.should have_tag('form.destroy_table') do
      with_tag('input[type=hidden][name=return_to][value=url]')
    end
  end
  
  it "should issue a deprecation warning when passing in parameters vie :parameters" do
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.destroy_table(@table, :parameters => {:return_to => 'url'})
  end
  
end



describe 'destroy_resource with plural resource and block' do

  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_path).and_return('/tables/1')
    @table = mock('table', :to_param => 1)
  end
  
  it "should render a 'destroy_table' form" do
    pending
    _erbout = ''
    @view.destroy_table(@table) do |form|
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.destroy.table.destroy_table', 'some-content')
  end
  
end



describe 'destroy_resource with plural nested resource' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_leg_path).and_return('/tables/1/leg/1')
    @table = mock('table')
    @leg = mock('leg')
  end
  
  it "should create a form with resourceful classes" do
    markup = @view.destroy_table_leg(@table, @leg)
    markup.should have_tag('form.destroy.leg.destroy_leg')
  end

  it "should allow adding custom classes" do
    markup = @view.destroy_table_leg(@table, @leg, :class => 'metal')
    markup.should have_tag('form.destroy.leg.metal.destroy_leg.metal_leg')
  end
  
  it "should submit to the resource_path" do
    @view.should_receive(:table_leg_path).with(@table, @leg).and_return('/tables/1/legs/1')
    markup = @view.destroy_table_leg(@table, @leg)
    markup.should have_tag('form[action=/tables/1/legs/1]')
  end
  
  it "should send the method 'delete' as a hidding field" do
    markup = @view.destroy_table_leg(@table, @leg)
    markup.should have_tag('form input[type=hidden][name=_method][value=delete]')
  end
  
  it "should have a submit button labeled 'Delete' by default" do
    markup = @view.destroy_table_leg(@table, @leg)
    markup.should have_tag('form button[type=submit]', 'Delete')
  end
  
  it "should allow passing in a custom label to be used for the button" do
    markup = @view.destroy_table_leg(@table, @leg, :label => 'Remove')
    markup.should have_tag('form button[type=submit]', 'Remove')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.destroy_table_leg(@table, @leg, :button => {:title => 'Click to remove leg'})
    markup.should have_tag('form.destroy_leg') do
      with_tag('button[type=submit][title=Click to remove leg]')
    end
  end
  
end



describe 'destroy_resource with singular nested resource' do
  
  before do
    ResourcefulViews.form_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resource :top
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:protect_against_forgery?).and_return(false)
    @view.stub!(:table_top_path).and_return('/tables/1/top')
    @table = mock('table')
  end
  
  it "should create a form with resourceful classes" do
    markup = @view.destroy_table_top(@table)
    markup.should have_tag('form.destroy.top.destroy_top')
  end

  it "should allow adding custom classes" do
    markup = @view.destroy_table_top(@table, :class => 'linoleum')
    markup.should have_tag('form.destroy.top.linoleum.destroy_top.linoleum_top')
  end
  
  it "should submit to the resource_path" do
    @view.should_receive(:table_top_path).with(@table).and_return('/tables/1/top')
    markup = @view.destroy_table_top(@table)
    markup.should have_tag('form[action=/tables/1/top]')
  end
  
  it "should send the method 'delete' as a hidding field" do
    markup = @view.destroy_table_top(@table)
    markup.should have_tag('form input[type=hidden][name=_method][value=delete]')
  end
  
  it "should have a submit button labeled 'Delete' by default" do
    markup = @view.destroy_table_top(@table)
    markup.should have_tag('form button[type=submit]', 'Delete')
  end
  
  it "should allow passing in a custom label to be used for the button" do
    markup = @view.destroy_table_top(@table, :label => 'Remove')
    markup.should have_tag('form button[type=submit]', 'Remove')
  end
  
  it "should allow for setting the title attribute of the submit button via the :title option" do
    markup = @view.destroy_table_top(@table, :button => {:title => 'Click to remove top'})
    markup.should have_tag('form.destroy_top') do
      with_tag('button[type=submit][title=Click to remove top]')
    end
  end
  
end


describe 'destroy_resource with form_helpers_suffix set' do
  
  before do
    ResourcefulViews.form_helpers_suffix = '_form'
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
        table.resource :top
      end
    end
    @view = ActionView::Base.new
  end
  
  it "should define helpers with suffix" do
    @view.should respond_to(:destroy_table_form)
    @view.should respond_to(:destroy_table_leg_form)
    @view.should respond_to(:destroy_table_top_form)
  end
  
end

