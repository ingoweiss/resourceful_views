require File.dirname(__FILE__) + '/spec_helper'


describe 'new_resource with plural resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:new_table_path).and_return('/tables/new')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_table
    markup.should have_tag('a.new.table.new_table')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_table(:class => 'dining')
    markup.should have_tag('a.new.table.dining.new_table.dining_table')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_table_path).and_return('/tables/new')
    markup = @view.new_table
    markup.should have_tag('a[href=/tables/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_table
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_table(:label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.new_table(:title => 'Click to create new')
    markup.should have_tag('a[title=Click to create new]')
  end
  
  it "should allow specifying additional parameters to be sent via the :sending option" do
    @view.should_receive(:new_table_path).with(:my_param => 'my_value').and_return('/tables/new?my_param=my_value')
    markup = @view.new_table(:sending => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/tables/new?my_param=my_value]')
  end
  
  it "should allow specifying additional parameters to be sent via the :parameters option" do
    @view.should_receive(:new_table_path).with(:my_param => 'my_value').and_return('/tables/new?my_param=my_value')
    markup = @view.new_table(:parameters => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/tables/new?my_param=my_value]')
  end
  
  it "should allow passing in of resource attributes via :with" do
    @view.should_receive(:new_table_path).with('table[my_attribute]' => 'my_value').and_return('/tables/new?table[my_attribute]=my_value')
    markup = @view.new_table(:with => {:my_attribute => 'my_value'})
    markup.should have_tag("a[href='/tables/new?table[my_attribute]=my_value']")
  end
  
  it "should allow passing in of resource attributes via :attributes (deprecated)" do
    @view.should_receive(:new_table_path).with('table[my_attribute]' => 'my_value').and_return('/tables/new?table[my_attribute]=my_value')
    markup = @view.new_table(:attributes => {:my_attribute => 'my_value'})
    markup.should have_tag("a[href='/tables/new?table[my_attribute]=my_value']")
  end
  
  it "should issue a deprecation warning if passing in resource attributes via :attributes" do
    ResourcefulViews.should_receive(:deprecation_warning)
    markup = @view.new_table(:attributes => {:my_attribute => 'my_value'})
  end
  
  it "should support :parameters and :with options together (exposes bug)" do  
    @view.should_receive(:new_table_path).with('table[my_attribute]' => 'my_value', :my_param => 'my_value').and_return('/tables/new?table[my_attribute]=my_value&my_param=my_value')
    markup = @view.new_table(:with => {:my_attribute => 'my_value'}, :parameters => {:my_param => 'my_value'})
  end

end


describe 'new_resource with plural resource and block' do
  
  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables
    end
    @view = ActionView::Base.new
    @view.stub!(:new_table_path).and_return('/tables/new')
  end
  
  it "should create a form with resourceful classes" do
    _erbout = ''
    @view.new_table do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.new_table')
  end
  
  it "should allow adding custom classes" do
    _erbout = ''
    @view.new_table(:class => 'vintage') do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.new_table.vintage_table')
  end
  
  it "should GET to the new_resource_path" do
    _erbout = ''
    @view.new_table do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form[method=get][action=/tables/new]')
  end     
  
  it "should allow specifying additional parameters to be sent via the :sending option" do
    _erbout = ''
    @view.new_table :sending => {:my_param => 'my_value'} do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.new_table') do
       with_tag('input[type=hidden][name=my_param][value=my_value]')
    end
  end
  
  it "should allow specifying additional parameters to be sent via the :parameters option (legacy)" do
    _erbout = ''
    @view.new_table :parameters => {:my_param => 'my_value'} do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.new_table') do
       with_tag('input[type=hidden][name=my_param][value=my_value]')
    end
  end
  
  it "should issue a deprecation warning when specifying additional parameters the :parameters option" do
    ResourcefulViews.should_receive(:deprecation_warning)
    _erbout = ''
    @view.new_table :parameters => {:my_param => 'my_value'} do
       # something
    end
  end
  
  it "should support :with option" do
    _erbout = ''
    @view.new_table(:with => {:material => 'wood'}) do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.new_table') do
       with_tag("input[type=hidden][name='table[material]'][value=wood]")
    end
  end
  
  it "should support :attributes option (deprecated)" do
    _erbout = ''
    @view.new_table(:attributes => {:material => 'wood'}) do
       _erbout << 'some-content'
    end
    _erbout.should have_tag('form.new_table') do
       with_tag("input[type=hidden][name='table[material]'][value=wood]")
    end
  end
  
  it "should issue a deprecation warning when passing in attributes via :attributes" do
    _erbout = ''
    ResourcefulViews.should_receive(:deprecation_warning)
    @view.new_table(:attributes => {:material => 'wood'}) do
       # something
    end
  end
  
  it "should allow for building form fields with yielded form builder" do
    _erbout = ''
    @view.new_table do |form|
       _erbout << form.text_field(:name)
    end
    _erbout.should have_tag("form.new_table") do
       with_tag("input[type=text][name='table[name]']")
    end
  end
  
end


describe 'new_resource with plural nested resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resources :legs
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:new_table_leg_path).and_return('/tables/1/legs/new')
    @table = mock('table')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_table_leg(@table)
    markup.should have_tag('a.new.leg.new_leg')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_table_leg(:class => 'metal')
    markup.should have_tag('a.new.leg.metal.new_leg.metal_leg')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_table_leg_path).and_return('/tables/1/legs/new')
    markup = @view.new_table_leg(@table)
    markup.should have_tag('a[href=/tables/1/legs/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_table_leg(@table)
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_table_leg(@table, :label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.new_table_leg(@table, :title => 'Click to create new')
    markup.should have_tag('a[title=Click to create new]')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:new_table_leg_path).with(@table, :my_param => 'my_value').and_return('/tables/1/legs/new?my_param=my_value')
    markup = @view.new_table_leg(@table, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/tables/1/legs/new?my_param=my_value]')
  end
  
end


describe 'new_resource for singular nested resource' do

  before do
    ResourcefulViews.link_helpers_suffix = nil
    ActionController::Routing::Routes.draw do |map|
      map.resources :tables do |table|
        table.resource :top
      end
    end
    @view = ActionView::Base.new
    @view.stub!(:new_table_top_path).and_return('/tables/1/top/new')
    @table = mock('table')
  end
  
  it "should create a link with resourceful classes" do
    markup = @view.new_table_top(@table)
    markup.should have_tag('a.new.top.new_top')
  end
  
  it "should allow adding custom classes" do
    markup = @view.new_table_top(@table, :class => 'wood')
    markup.should have_tag('a.new.top.wood.new_top.wood_top')
  end
  
  it "should link to the new_resource_path" do
    @view.should_receive(:new_table_top_path).with(@table).and_return('/tables/1/top/new')
    markup = @view.new_table_top(@table)
    markup.should have_tag('a[href=/tables/1/top/new]')
  end
  
  it "should have the label 'New' by default" do
    markup = @view.new_table_top(@table)
    markup.should have_tag('a', 'New')
  end
  
  it "should allow passing in a custom label" do
    markup = @view.new_table_top(@table, :label => 'Add')
    markup.should have_tag('a', 'Add')
  end
  
  it "should allow for setting the title attribute of the link via the :title option" do
    markup = @view.new_table_top(@table, :title => 'Click to create new')
    markup.should have_tag('a[title=Click to create new]')
  end
  
  it "should pass additional options on to the named route helper" do
    @view.should_receive(:new_table_top_path).with(@table, :my_param => 'my_value').and_return('/tables/1/top/new?my_param=my_value')
    markup = @view.new_table_top(@table, :parameters => {:my_param => 'my_value'})
    markup.should have_tag('a[href=/tables/1/top/new?my_param=my_value]')
  end
    
end


describe 'new_resource with form_helpers_suffix set' do
  
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
    @view.should respond_to(:new_table_link)
    @view.should respond_to(:new_table_leg_link)
    @view.should respond_to(:new_table_top_link)
  end                        
  
end