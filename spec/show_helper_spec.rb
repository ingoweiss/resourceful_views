require File.dirname(__FILE__) + '/spec_helper'


describe 'show_resource with plural resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:table_path).and_return('/tables/1')
    @table = mock('table', :to_param => 1, :to_s => 'Dining Table')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.show_table(@table)
    markup.should have_tag('a.show.table.show_table')
  end
  
  it "should allow adding custom classes" do
    markup = @view.show_table(@table, :class => 'dining')
    markup.should have_tag('a.show.table.dining.show_table.dining_table')
  end
  
  it "should link to the resource_path" do
    @view.should_receive(:table_path).with(@table).and_return('/tables/1')
    markup = @view.show_table(@table)
    markup.should have_tag('a[href=/tables/1]')
  end
  
  it "should pass :anchor option on to the named route helper" do
    pending
    @view.should_receive(:table_path).with(@table, :anchor => 'special').and_return('/tables/1#special')
    markup = @view.show_table(@table, :anchor => 'special')
    markup.should have_tag('a[href=/tables/1#special]')
  end
  
  it "should use the return value of the model's 'to_s' method as a label by default" do
    @table.should_receive(:to_s).and_return('Walnut-top dining table')
    markup = @view.show_table(@table)
    markup.should have_tag('a', 'Walnut-top dining table')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.show_table(@table, :label => 'Details')
    markup.should have_tag('a', 'Details')
  end
  
  it "should allow specifying additional parameters to be sent via the :sending option" do
    @view.should_receive(:table_path).with(@table, :my_param => 'my_value').and_return('/table/1?my_param=my_value')
    markup = @view.show_table(@table, :sending => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/table/1?my_param=my_value]')
  end 
  
  it "should allow specifying additional parameters to be sent via the :parameters option (legacy)" do
    @view.should_receive(:table_path).with(@table, :my_param => 'my_value').and_return('/table/1?my_param=my_value')
    markup = @view.show_table(@table, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/table/1?my_param=my_value]')
  end
  
  it "should issue a deprecation warning when specifying parameters via :parameters" do
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.show_table(@table, :parameters => {:my_param => 'my_value'})
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.show_table(@table, :title => 'Click to view details')
    markup.should have_tag('a[title=Click to view details]')
  end
  
end


describe 'show_resource with plural nested resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:table_leg_path).and_return('/tables/1/legs/1')
    @table = mock('table')
    @leg = mock('leg', :to_s => 'Metal leg')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.show_table_leg(@table, @leg)
    markup.should have_tag('a.show.leg.show_leg')
  end
  
  it "should allow adding custom classes" do
    markup = @view.show_table_leg(@table, @leg, :class => 'metal')
    markup.should have_tag('a.show.leg.metal.show_leg.metal_leg')
  end
  
  it "should link to the resource_path" do
    @view.should_receive(:table_leg_path).with(@table, @leg).and_return('/tables/1/legs/1')
    markup = @view.show_table_leg(@table, @leg)
    markup.should have_tag('a[href=/tables/1/legs/1]')
  end
  
  it "should use the return value of the model's 'to_s' method as a label by default" do
    @leg.should_receive(:to_s).and_return('Brushed-metal leg')
    markup = @view.show_table_leg(@table, @leg)
    markup.should have_tag('a', 'Brushed-metal leg')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.show_table_leg(@table, @leg, :label => 'Details')
    markup.should have_tag('a', 'Details')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:table_leg_path).with(@table, @leg, :my_param => 'my_value').and_return('/table/1/leg?my_param=my_value')
    markup = @view.show_table_leg(@table, @leg, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/table/1/leg?my_param=my_value]')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.show_table_leg(@table, @leg, :title => 'Click to view details')
    markup.should have_tag('a[title=Click to view details]')
  end
  
end


describe 'show_resource for singular nested resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
        table.resource :top
      end
    end
    @view = ActionView::Base.new
    @table = mock('table')
    @top = mock('top')
    @view.stub!(:table_top_path).and_return('/table/1/top')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.show_table_top(@table)
    markup.should have_tag('a.show.top.show_top')
  end
  
  it "should allow adding custom classes" do 
    markup = @view.show_table_top(@table, :class => 'linoleum')
    markup.should have_tag('a.show.top.linoleum.show_top.linoleum_top')
  end
  
  it "should link to the resource_path" do    
    @view.should_receive(:table_top_path).with(@table).and_return('/table/1/top')
    markup = @view.show_table_top(@table)
    markup.should have_tag('a[href=/table/1/top]')
  end
  
  # We can not easily derive a default here from the parameters provided
  # Without going through the AR association about which RV probably should hot make any assumptions
  it "should use 'Show' as a label by default" do
    markup = @view.show_table_top(@table)
    markup.should have_tag('a', 'Show')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.show_table_top(@table, :label => 'Details')
    markup.should have_tag('a', 'Details')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:table_top_path).with(@table, @top, :my_param => 'my_value').and_return('/table/1/top?my_param=my_value')
    markup = @view.show_table_top(@table, @top, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/table/1/top?my_param=my_value]')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.show_table_top(@table, @top, :title => 'Click to view details')
    markup.should have_tag('a[title=Click to view details]')
  end
  
end

describe 'show_resource with form_helpers_suffix set' do
  
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
    @view.should respond_to(:show_table_link)
    @view.should respond_to(:show_table_leg_link)
    @view.should respond_to(:show_table_top_link)
  end                        
  
end