require File.dirname(__FILE__) + '/spec_helper'


describe 'index_resource with plural resource' do
  
  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:tables_path).and_return('/tables')
  end

  it "should create a link with resourceful classes" do
    markup = @view.index_tables
    markup.should have_tag('a.index.tables.index_tables')
  end
  
  it "should allow adding custom classes" do
    markup = @view.index_tables(:class => 'dining')
    markup.should have_tag('a.index.tables.dining.index_tables.dining_tables')
  end
  
  it "should link to the resources_path" do
    @view.should_receive(:tables_path).and_return('/tables')
    markup = @view.index_tables
    markup.should have_tag('a[href=/tables]')
  end
  
  it "should have the label 'Index' by default" do
    markup = @view.index_tables
    markup.should have_tag('a', 'Index')
  end
  
  it "should allow passing in a custom label" do
    @view.should_receive(:tables_path).and_return('/tables')
    markup = @view.index_tables(:label => 'Back')
    markup.should have_tag('a', 'Back')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.index_tables(:title => 'Click to go back to index')
    markup.should have_tag('a[title=Click to go back to index]')
  end
  
  it "should allow for giving the link an id via the :id option" do
    markup = @view.index_tables(:id => 'back_button')
    markup.should have_tag('a#back_button')
  end
  
  it "should allow passing additional parameters to the named route helper via the :sending option" do
    @view.should_receive(:tables_path).with(:my_param => 'my_value').and_return('/tables?my_param=my_value')
    markup = @view.index_tables(:sending => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/tables?my_param=my_value]')
  end
  
  it "should allow passing additional parameters to the named route helper via the :parameters option" do
    @view.should_receive(:tables_path).with(:my_param => 'my_value').and_return('/tables?my_param=my_value')
    markup = @view.index_tables(:parameters => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/tables?my_param=my_value]')
  end
  
  it "should issue a deprecation warning when passing in parameters with :parameters" do
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.index_tables(:parameters => {:my_param => 'my_value'})
  end
  
end


describe 'index_resource with plural nested resource' do
  
  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:table_legs_path).and_return('/tables/1/legs')
    @table = mock('table')
  end

  it "should create a link with resourceful classes" do
    markup = @view.index_table_legs(@table)
    markup.should have_tag('a.index.legs.index_legs')
  end
  
  it "should allow adding custom classes" do
    markup = @view.index_table_legs(@table, :class => 'metal')
    markup.should have_tag('a.index.legs.metal.index_legs.metal_legs')
  end
  
  it "should link to the resources_path" do
    @view.should_receive(:table_legs_path).with(@table).and_return('/tables/1/legs')
    markup = @view.index_table_legs(@table)
    markup.should have_tag('a[href=/tables/1/legs]')
  end
  
  it "should have the label 'Index' by default" do
    markup = @view.index_table_legs(@table)
    markup.should have_tag('a', 'Index')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.index_table_legs(@table, :label => 'Back')
    markup.should have_tag('a', 'Back')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.index_table_legs(@table, :title => 'Click to list')
    markup.should have_tag('a[title=Click to list]')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:table_legs_path).with(@table, :my_param => 'my_value').and_return('/tables/1/legs?my_param=my_value')
    markup = @view.index_table_legs(@table, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/tables/1/legs?my_param=my_value]')
  end
  
end


describe 'index_resource with form_helpers_suffix set' do
  
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
    @view.should respond_to(:index_tables_link)
    @view.should respond_to(:index_table_legs_link)
  end                        
  
end
