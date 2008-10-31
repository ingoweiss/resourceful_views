require File.dirname(__FILE__) + '/spec_helper'


describe 'edit_resource with plural resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:edit_table_path).and_return('/tables/1/edit')
    @table = mock('table', :to_param => 1)
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.edit_table(@table)
    markup.should have_tag('a.edit.table.edit_table')
  end
  
  it "should allow adding custom classes" do
    markup = @view.edit_table(@table, :class => 'dining')
    markup.should have_tag('a.edit.table.dining.edit_table.dining_table')
  end
  
  it "should link to the edit_resource_path" do
    @view.should_receive(:edit_table_path).with(@table).and_return('/tables/1/edit')
    markup = @view.edit_table(@table)
    markup.should have_tag('a[href=/tables/1/edit]')
  end
  
  it "should have the label 'Edit' by default" do
    markup = @view.edit_table(@table)
    markup.should have_tag('a', 'Edit')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.edit_table(@table, :label => 'Change')
    markup.should have_tag('a', 'Change')
  end
  
  it "should allow passing additional parameters to the named route helper via the :sending option" do
    @view.should_receive(:edit_table_path).with(@table, :my_param => 'my_value').and_return('/tables/1/edit?my_param=my_value')
    markup = @view.edit_table(@table, :sending => {:my_param => 'my_value'})
    markup.should have_tag('a.edit_table[href=/tables/1/edit?my_param=my_value]')
  end
  
  it "should allow passing additional parameters to the named route helper via the :parameters option (legacy)" do
    @view.should_receive(:edit_table_path).with(@table, :my_param => 'my_value').and_return('/tables/1/edit?my_param=my_value')
    markup = @view.edit_table(@table, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a.edit_table[href=/tables/1/edit?my_param=my_value]')
  end
  
  it "should issue a deprecation warning when passing in parameters via :parameters" do
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.edit_table(@table, :parameters => {:my_param => 'my_value'})
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.edit_table(@table, :title => 'Click to edit table')
    markup.should have_tag('a.edit_table[title=Click to edit table]')
  end
  
end


describe 'edit_resource with plural nested resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:edit_table_leg_path).and_return('/tables/1/legs/1/edit')
    @table = mock('table')
    @leg = mock('leg')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.edit_table_leg(@table, @leg)
    markup.should have_tag('a.edit.leg.edit_leg')
  end
  
  it "should allow adding custom classes" do
    markup = @view.edit_table_leg(@table, @leg, :class => 'wood')
    markup.should have_tag('a.edit.leg.wood.edit_leg.wood_leg')
  end
  
  it "should link to the edit_resource_path" do
    @view.should_receive(:edit_table_leg_path).with(@table, @leg).and_return('/tables/1/legs/1/edit')
    markup = @view.edit_table_leg(@table, @leg)
    markup.should have_tag('a[href=/tables/1/legs/1/edit]')
  end
  
  it "should have the label 'Edit' by default" do
    markup = @view.edit_table_leg(@table, @leg)
    markup.should have_tag('a', 'Edit')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.edit_table_leg(@table, @leg, :label => 'Change')
    markup.should have_tag('a', 'Change')
  end
  
  it "should allow passing additional parameters to the named route helper via the :parameters option" do
    @view.should_receive(:edit_table_leg_path).with(@table, @leg, :my_param => 'my_value').and_return('/tables/1/legs/1/edit?my_param=my_value')
    markup = @view.edit_table_leg(@table, @leg, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a.edit_leg[href=/tables/1/legs/1/edit?my_param=my_value]')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.edit_table_leg(@table, @leg, :title => 'Click to edit leg')
    markup.should have_tag('a.edit_leg[title=Click to edit leg]')
  end
  
end  



describe 'edit_resource for singular nested resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resource :top
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:edit_table_top_path).and_return('/tables/1/top/edit')
    @table = mock('table')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.edit_table_top(@table)
    markup.should have_tag('a.edit.top.edit_top')
  end
  
  it "should allow adding custom classes" do
    markup = @view.edit_table_top(@table, :class => 'linoleum')
    markup.should have_tag('a.edit.top.linoleum.edit_top.linoleum_top')
  end
  
  it "should link to the edit_resource_path" do
    @view.should_receive(:edit_table_top_path).with(@table).and_return('/tables/1/top/edit')
    markup = @view.edit_table_top(@table) 
    markup.should have_tag('a[href=/tables/1/top/edit]')
  end
  
  it "should have the label 'Edit' by default" do
    markup = @view.edit_table_top(@table) 
    markup.should have_tag('a', 'Edit')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.edit_table_top(@table, :label => 'Change')
    markup.should have_tag('a', 'Change')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:edit_table_top_path).with(@table, :my_param => 'my_value').and_return('/tables/1/top/edit?my_param=my_value')
    markup = @view.edit_table_top(@table, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a.edit_top[href=/tables/1/top/edit?my_param=my_value]')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.edit_table_top(@table, :title => 'Click to edit top')
    markup.should have_tag('a.edit_top[title=Click to edit top]')
  end
  
end

describe 'edit_resource with form_helpers_suffix set' do
  
  before do
    ResourcefulViews.link_helpers_suffix = '_link'
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
        table.resource :top
      end
    end
    @view = ActionView::Base.new
  end
  
  it "should define helpers with suffix" do
    @view.should respond_to(:edit_table_link)
    @view.should respond_to(:edit_table_leg_link)
    @view.should respond_to(:edit_table_top_link)
  end                        
  
end

